//
//  ProductDetailViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/21/24.
//

import UIKit
import WebKit

import iamport_ios
import RxSwift
import RxCocoa
import SnapKit

final class ProductDetailViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let viewModel: any BaseViewModel
    
    private let disposeBag = DisposeBag()
    
    private let editMenuTapped = PublishRelay<Void>()
    private let deleteMenuTapped = PublishRelay<Void>()
    private let fetch = PublishRelay<Void>()
    
    //MARK: - Init
    
    init(viewModel: any BaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private let scrollView = UIScrollView()
    
    private let scrollContainerView = UIView()
    
    private let pageControl = UIPageControl()
    
    private lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.register(DetailCollectionViewCell.self, forCellWithReuseIdentifier: DetailCollectionViewCell.identifier)
        cv.backgroundColor = .lightGray
        cv.layer.cornerRadius = 20
        cv.contentInsetAdjustmentBehavior = .never
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let profileTapGesture = UITapGestureRecognizer()
    private let nicknameTapGesture = UITapGestureRecognizer()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        iv.backgroundColor = .lightGray
        iv.addGestureRecognizer(profileTapGesture)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryTitleFont
        label.textColor = Constant.Color.Text.titleColor
        label.addGestureRecognizer(nicknameTapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.titleFont
        label.numberOfLines = 0
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryTitleFont
        label.textColor = Constant.Color.Text.brandTitleColor
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.priceFont
        label.textColor = Constant.Color.Text.titleColor
        label.textAlignment = .right
        return label
    }()
    
    private let createdDateLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.infoFont
        label.textColor = Constant.Color.Text.secondaryColor
        return label
    }()
    
    private let conditionTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
        label.text = "컨디션"
        return label
    }()
    
    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
        return label
    }()
    
    private let sizeTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
        label.text = "사이즈"
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
        return label
    }()
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
        label.text = "카테고리"
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryTitleFont
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
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .init(width: 0, height: 0)
        view.backgroundColor = Constant.Color.View.viewBackgroundColor
        return view
    }()
    
    private let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        btn.tintColor = Constant.Color.Button.titleColor
        btn.backgroundColor = Constant.Color.brandColor
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = .init(width: 0, height: 1)
        return btn
    }()
    
    private let commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "captions.bubble.fill")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        btn.tintColor = Constant.Color.Button.titleColor
        btn.backgroundColor = Constant.Color.brandColor
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor.lightGray.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = .init(width: 0, height: 1)
        return btn
    }()
    
    private let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("구매하기", for: .normal)
        button.titleLabel?.font = Constant.Font.buttonTitleFont
        button.backgroundColor = Constant.Color.brandColor
        button.tintColor = Constant.Color.Button.titleColor
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = .init(width: 0, height: 1)
        return button
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.backward")?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 17))), for: .normal)
        btn.tintColor = .white
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = .init(width: 0, height: 1)
        return btn
    }()
    
    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "ellipsis.circle")?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 17))), for: .normal)
        btn.tintColor = .white
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowOffset = .init(width: 0, height: 1)
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()
    
    private let profileBottomSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let contentTopSeparatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        fetch.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        if let viewModel = viewModel as? ProductDetailViewModel {
            
            let deleteAlertButtonTapped = PublishRelay<Void>()
            let executePayment = PublishRelay<String>()
            let profileTapped = PublishRelay<Void>()
            
            let input = ProductDetailViewModel.Input(
                fetchData: fetch,
                backButtonTapped: backButton.rx.tap,
                likeButtonTapped: likeButton.rx.tap,
                editMenuButtonTapped: editMenuTapped,
                deleteMenuButtonTapped: deleteMenuTapped, 
                deleteAlertButtonTapped: deleteAlertButtonTapped,
                commentButtonTapped: commentButton.rx.tap,
                buyButtonTapped: buyButton.rx.tap,
                executePayment: executePayment,
                profileTapped: profileTapped
            )
            let output = viewModel.transform(input: input)
            
            
            output.profileImageData
                .map { UIImage(data: $0) }
                .bind(to: profileImageView.rx.image)
                .disposed(by: disposeBag)
            
            output.nickname
                .bind(to: nicknameLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.title
                .bind(to: titleLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.brand
                .bind(to: brandLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.price
                .bind(to: priceLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.createDate
                .bind(to: createdDateLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.category
                .bind(to: categoryLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.condition
                .bind(to: conditionLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.size
                .bind(to: sizeLabel.rx.text)
                .disposed(by: disposeBag)
            
            output.content
                .bind(to: contentTextView.rx.text)
                .disposed(by: disposeBag)
            
            output.soldStatus
                .bind(with: self) { owner, value in
                    owner.updateBuyButtonAppearance(isNotSold: value)
                }
                .disposed(by: disposeBag)
            
            output.productImageDatas
                .share()
                .bind(to: collectionView.rx.items(cellIdentifier: DetailCollectionViewCell.identifier, cellType: DetailCollectionViewCell.self)) { row, element, cell in
                    cell.productImageView.image = UIImage(data: element)
                }
                .disposed(by: disposeBag)
            
            output.productImageDatas
                .map { $0.count }
                .bind(to: pageControl.rx.numberOfPages)
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
            
            output.likeStatus
                .bind(with: self) { owner, value in
                    owner.updateLikeButtonAppearance(isLiked: value)
                }
                .disposed(by: disposeBag)
                
            
            output.networkError
                .bind(with: self) { owner, value in
                    owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
                }
                .disposed(by: disposeBag)
            
            output.backButtonTapped
                .bind(with: self) { owner, _ in
                    owner.popViewController()
                }
                .disposed(by: disposeBag)
            
            output.editMenuButtonTapped
                .bind(with: self) { [weak self] owner, value in
                    let vm = ProductPostEditViewModel(viewType: .modify)
                    vm.productPost = value
                    
                    vm.postUploadSucceed = { [weak self] sender in
                        guard let self else { return }
                        self.showToast(message: "상품이 수정되었습니다🎉", position: .bottom)
                        
                        self.fetch.accept(())
                    }
                    let vc = ProductPostEditViewController(viewModel: vm)
                    let navi = UINavigationController(rootViewController: vc)
                    navi.modalPresentationStyle = .fullScreen
                    owner.present(navi, animated: true)
                }
                .disposed(by: disposeBag)
            
            output.deleteMenuButtonTapped
                .bind(with: self) { owner, _ in
                    owner.showDeleteCheckAlert { okAction in
                        deleteAlertButtonTapped.accept(())
                    }
                }
                .disposed(by: disposeBag)
            
            output.rejectionEdit
                .bind(with: self) { owner, value in
                    owner.showToast(message: "판매된 상품의 게시물은 \(value)할 수 없습니다", position: .center)
                }
                .disposed(by: disposeBag)
            
            output.succeedDelete
                .bind(with: self) { owner, _ in
                    viewModel.postDeleteSucceed()
                    owner.popViewController()
                }
                .disposed(by: disposeBag)
            
            output.hideMenuButton
                .bind(to: menuButton.rx.isHidden)
                .disposed(by: disposeBag)
            
            output.commentButtonTapped
                .bind(with: self) { owner, value in
                    let vm = CommentViewModel(postID: value.post_id, comments: value.comments)
                    vm.newCommentUpload = {
                        owner.fetch.accept(())
                    }
                    let vc = CommentViewController(viewModel: vm)
                    owner.pushViewController(vc)
                }
                .disposed(by: disposeBag)
            
            output.buyButtonTapped
                .bind(with: self) { owner, value in
                    if let naviController = owner.navigationController {
                        
                        Iamport.shared.payment(navController: naviController, userCode: APIKey.userCode, payment: value) { iamportResponse in
                            
                            if let success = iamportResponse?.success, success {
                                if let impUID = iamportResponse?.imp_uid {
                                    executePayment.accept(impUID)
                                }
                            }
                        }
                    }
                }
                .disposed(by: disposeBag)
            
            output.succeedPayment
                .bind(with: self) { owner, _ in
                    owner.showPaymentCompletedAlert()
                    owner.updateBuyButtonAppearance(isNotSold: false)
                }
                .disposed(by: disposeBag)
            
            self.collectionView.rx.setDelegate(self)
                .disposed(by: disposeBag)
            
            self.profileTapGesture.rx.event
                .bind { _ in
                    profileTapped.accept(())
                }
                .disposed(by: disposeBag)
            
            self.nicknameTapGesture.rx.event
                .bind { _ in
                    profileTapped.accept(())
                }
                .disposed(by: disposeBag)
            
            output.goToProfileDetail
                .bind(with: self) { owner, value in
                    var vm: ProfileViewModel
                    
                    if value == UserDefaultsManager.shared.userID {
                        vm = ProfileViewModel(viewType: .loginUser, userID: value, isTapBarView: false)
                    } else {
                        vm = ProfileViewModel(viewType: .notLoginUser, userID: value, isTapBarView: false)
                    }
                    
                    let vc = ProfileViewController(viewModel: vm)
                    owner.pushViewController(vc)
                }
                .disposed(by: disposeBag)
        }
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
    
    override func setupNavi() {
        navigationItem.title = ""
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.addSubviews(
            collectionView,
            pageControl,
            profileImageView,
            nicknameLabel,
            profileBottomSeparatorLine,
            titleLabel,
            brandLabel,
            priceLabel,
            createdDateLabel,
            conditionTitleLabel,
            conditionLabel,
            sizeTitleLabel,
            sizeLabel,
            categoryTitleLabel,
            categoryLabel,
            contentTopSeparatorLine,
            contentTextView
        )
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubviews(
            likeButton,
            commentButton,
            buyButton
        )
        view.addSubview(backButton)
        view.addSubview(menuButton)
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollContainerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
            make.verticalEdges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(470)
        }
        
        pageControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(collectionView.snp.bottom).offset(-20)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.size.equalTo(44)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        profileBottomSeparatorLine.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.height.equalTo(10)
            make.horizontalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileBottomSeparatorLine.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        createdDateLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        conditionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(createdDateLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(20)
        }
        
        conditionLabel.snp.makeConstraints { make in
            make.top.equalTo(conditionTitleLabel.snp.top)
            make.trailing.equalToSuperview().inset(20)
        }
        
        sizeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(conditionTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.top.equalTo(sizeTitleLabel.snp.top)
            make.trailing.equalToSuperview().inset(20)
        }
        
        categoryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(sizeTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.top)
            make.trailing.equalToSuperview().inset(20)
        }
        
        contentTopSeparatorLine.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(13)
            make.height.equalTo(10)
            make.horizontalEdges.equalToSuperview()
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentTopSeparatorLine.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(100)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
        }
        
        commentButton.snp.makeConstraints { make in
            make.size.equalTo(50)
            make.top.equalToSuperview().inset(20)
            make.leading.equalTo(likeButton.snp.trailing).offset(15)
        }
        
        buyButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalToSuperview().inset(20)
            make.leading.equalTo(commentButton.snp.trailing).offset(15)
            make.trailing.equalToSuperview().inset(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(44)
        }
        
        menuButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(44)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    //MARK: - Methods
    
    private func updateLikeButtonAppearance(isLiked: Bool) {
        if isLiked {
            self.likeButton.setImage(UIImage(systemName: "suit.heart.fill")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
            self.likeButton.tintColor = Constant.Color.Button.likeColor
        } else {
            self.likeButton.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
            self.likeButton.tintColor = .white
        }
    }
    
    private func showDeleteCheckAlert(okAction: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: "등록 상품 삭제", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive, handler: okAction))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
    }
    
    private func showPaymentCompletedAlert() {
        let alert = UIAlertController(title: "구매 완료", message: "결제가 완료되었습니다🎉", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    private func updateBuyButtonAppearance(isNotSold: Bool) {
        if isNotSold {
            buyButton.setTitle("구매하기", for: .normal)
            buyButton.backgroundColor = Constant.Color.brandColor
            buyButton.isEnabled = true
        } else {
            buyButton.isEnabled = false
            buyButton.setTitle("판매완료", for: .normal)
            buyButton.backgroundColor = Constant.Color.Button.buttonDisabled
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = collectionView.frame.size.height
        return CGSize(width: view.frame.size.width, height: collectionViewHeight)
    }
}
