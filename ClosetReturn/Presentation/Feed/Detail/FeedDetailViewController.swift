//
//  FeedDetailViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class FeedDetailViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: FeedDetailViewModel
    
    private let fetch = PublishRelay<Void>()
    private let editMenuTapped = PublishRelay<Void>()
    private let deleteMenuTapped = PublishRelay<Void>()
    
    //MARK: - Init
    
    init(viewModel: FeedDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryTitleFont
        label.textColor = Constant.Color.Text.titleColor
        return label
    }()
    
    private let pageControl = UIPageControl()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.width * 1.3)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        cv.contentInsetAdjustmentBehavior = .never
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis")?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 17))), for: .normal)
        btn.tintColor = .black
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()
    
    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = Constant.Color.Text.titleColor
        return label
    }()
    
    private let commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "captions.bubble")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = Constant.Color.Text.titleColor
        return label
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.font = Constant.Font.bodyFont
        tv.textColor = Constant.Color.Text.bodyColor
        return tv
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.infoFont
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "게시물"
        fetch.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let alertDeleteButtonTapped = PublishRelay<Void>()
        
        let input = FeedDetailViewModel.Input(
            fetch: fetch,
            likeButtonTapped: likeButton.rx.tap,
            editButtonTapped: editMenuTapped,
            deleteButtonTapped: deleteMenuTapped,
            alertDeleteButtonTapped: alertDeleteButtonTapped,
            commentButtonTapped: commentButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        let feedImageList = output.feedImages.share()
        
        feedImageList
            .bind(to: collectionView.rx.items(cellIdentifier: DetailCollectionViewCell.identifier, cellType: DetailCollectionViewCell.self)) { row, element, cell in
                cell.productImageView.image = UIImage(data: element)
            }
            .disposed(by: disposeBag)
        
        feedImageList
            .map { $0.count }
            .bind(with: self) { owner, value in
                if value <= 1 {
                    owner.pageControl.isHidden = true
                } else {
                    owner.pageControl.isHidden = false
                }
                owner.pageControl.numberOfPages = value
            }
            .disposed(by: disposeBag)
        
        output.profileImage
            .map { UIImage(data: $0) }
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.nickname
            .bind(to: nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.likeCount
            .map { $0.formatted() }
            .bind(to: likeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.commentCount
            .map { $0.formatted() }
            .bind(to: commentCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.content
            .bind(to: contentTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.date
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.like
            .bind(with: self) { owner, value in
                owner.updateLikeButtonAppearance(isLiked: value)
            }
            .disposed(by: disposeBag)
        
        output.hideMenuButton
            .bind(to: menuButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        collectionView.rx.contentOffset
            .map { [weak self] contentOffset -> CGFloat in
                guard let self = self else { return 0.0 }
                return contentOffset.x / self.view.frame.size.width
            }
            .map { CGFloat((round($0))) }
            .map { Int($0) }
            .bind(to: pageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        output.editButtonTapped
            .bind(with: self) { owner, value in
                let vm = FeedEditViewModel(viewType: .modify)
                vm.postID = value.0
                vm.content = value.1
                vm.images = value.2
                vm.postUploadSucceed = {
                    owner.showToast(message: "피드가 수정되었습니다", position: .bottom)
                    owner.fetch.accept(())
                }
                let vc = FeedEditViewController(viewModel: vm)
                let navi = UINavigationController(rootViewController: vc)
                owner.present(navi, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.deleteButtonTapped
            .bind(with: self) { owner, _ in
                owner.showDeleteCheckAlert { deleteAction in
                    alertDeleteButtonTapped.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        output.deleteSucceed
            .bind(with: self) { owner, _ in
                owner.viewModel.postDeleteSucceed()
                owner.popViewController()
            }
            .disposed(by: disposeBag)
        
        output.commentButtonTapped
            .bind(with: self) { owner, value in
                let vm = CommentViewModel(postID: value.post_id, comments: value.comments)
                let vc = CommentViewController(viewModel: vm)
                owner.pushViewController(vc)
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupMenuButton() {
        let menu = UIMenu(title: "편집", children: [
            UIAction(title: "수정하기", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                self?.editMenuTapped.accept(())
            },
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteMenuTapped.accept(())
            }
        ])
        menuButton.menu = menu
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(
            profileImageView,
            nicknameLabel,
            menuButton,
            collectionView,
            pageControl,
            likeButton,
            likeCountLabel,
            commentButton,
            commentCountLabel,
            contentTextView,
            dateLabel
        )
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(view.frame.size.width)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
            make.size.equalTo(38)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.trailing.equalToSuperview().inset(10)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(view.frame.size.width * 1.3)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton)
            make.leading.equalTo(likeButton.snp.trailing).offset(7)
        }
        
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(likeButton)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(15)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentButton)
            make.leading.equalTo(commentButton.snp.trailing).offset(7)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(30)
        }
        
        pageControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(collectionView.snp.bottom).offset(-20)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        contentTextView.backgroundColor = .white
        profileImageView.layer.cornerRadius = 19
    }
    
    //MARK: - Methods
    
    private func updateLikeButtonAppearance(isLiked: Bool) {
        if isLiked {
            self.likeButton.bounce()
            self.likeButton.setImage(UIImage(systemName: "suit.heart.fill")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
            self.likeButton.tintColor = Constant.Color.Button.likeColor
        } else {
            self.likeButton.bounce()
            self.likeButton.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
            self.likeButton.tintColor = .black
        }
    }
    
    private func showDeleteCheckAlert(okAction: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: "피드 삭제", message: "해당 피드를 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive, handler: okAction))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
    }
}

