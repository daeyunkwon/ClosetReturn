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
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.width)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        cv.contentInsetAdjustmentBehavior = .never
        cv.isPagingEnabled = true
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
        btn.setImage(UIImage(systemName: "captions.bubble.fill")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
    }
    
    private func setupMenuButton() {
        let menu = UIMenu(title: "편집", children: [
            UIAction(title: "수정하기", image: UIImage(systemName: "square.and.pencil")) { [weak self] _ in
                //self?.editMenuTapped.accept(())
            },
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                //self?.deleteMenuTapped.accept(())
            }
        ])
        menuButton.menu = menu
    }
    
    override func setupNavi() {
        navigationItem.title = "게시물"
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
            make.height.equalTo(view.frame.size.width)
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
    }
    
    override func configureUI() {
        super.configureUI()
        contentTextView.backgroundColor = .white
        profileImageView.layer.cornerRadius = 19
    }
}

