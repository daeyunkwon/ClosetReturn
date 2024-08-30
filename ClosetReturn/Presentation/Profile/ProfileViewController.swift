//
//  ProfileViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/28/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProfileViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileViewModel
    
    private let fetchUserProfile = PublishRelay<Void>()
    private let logoutMenuTapped = PublishRelay<Void>()
    private let withdrawalMenuTapped = PublishRelay<Void>()
    
    //MARK: - Init
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let topBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    private let bottomBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [feedCollectionView, productForSaleTableView, productForBuyTableView])
        sv.axis = .vertical
        return sv
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.systemGray5.cgColor
        iv.layer.borderWidth = 6
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let birthdayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "birthday.cake")?.applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 13, weight: .bold))), for: .normal)
        btn.tintColor = Constant.Color.Button.buttonDisabled
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    private let feedsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "피드", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    private let productsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "판매 상품", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "팔로워", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "팔로잉", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        return label
    }()
    
    private lazy var countInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [feedsLabel, productsLabel, followersLabel, followingLabel])
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 15
        return sv
    }()
    
    private let editAndFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("프로필 편집", for: .normal)
        button.titleLabel?.font = Constant.Font.buttonTitleFont
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = .init(width: 0, height: 1)
        return button
    }()
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["피드", "판매 중인 상품", "구매 내역"])
        sc.selectedSegmentIndex = 0
        sc.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)], for: .selected)
        sc.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        sc.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        sc.layer.cornerRadius = 10
        sc.layer.shadowColor = UIColor.lightGray.cgColor
        sc.layer.shadowOpacity = 0.3
        sc.layer.shadowOffset = .init(width: 0, height: 1)
        return sc
    }()
    
    private let feedRefreshControl = UIRefreshControl()
    
    private lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.size.width / 3 - 2, height: view.frame.size.width / 3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.identifier)
        cv.refreshControl = feedRefreshControl
        cv.isHidden = false
        cv.isScrollEnabled = false
        return cv
    }()
    
    private let productForSaleRefreshControl = UIRefreshControl()
    
    private lazy var productForSaleTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tv.rowHeight = 200
        tv.refreshControl = productForSaleRefreshControl
        tv.isHidden = true
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let productForBuyRefreshControl = UIRefreshControl()
    
    private lazy var productForBuyTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.register(ProductBuyTableViewCell.self, forCellReuseIdentifier: ProductBuyTableViewCell.identifier)
        tv.rowHeight = 150
        tv.refreshControl = productForBuyRefreshControl
        tv.isHidden = true
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "gearshape")?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 17))), for: .normal)
        btn.tintColor = .black
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuButton()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let fetchFeedCellImage = PublishRelay<(Int, String)>()
        let fetchBuyCellImage = PublishRelay<(Int, String)>()
        let logoutAlertButtonTapped = PublishRelay<Void>()
        
        
        let input = ProfileViewModel.Input(
            fetchUserProfile: self.fetchUserProfile,
            segmentControlIndexChange: segmentControl.rx.controlEvent(.valueChanged),
            fetchFeedCellImage: fetchFeedCellImage,
            fetchBuyCellImage: fetchBuyCellImage,
            logoutMenuTapped: logoutMenuTapped,
            withdrawalMenuTapped: withdrawalMenuTapped,
            logoutAlertButtonTapped: logoutAlertButtonTapped
        )
        let output = viewModel.transform(input: input)
        
        let feedList = output.feedPosts.share()
        let productList = output.productPosts.share()
        
        output.nickname
            .bind(to: nicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.followerCount
            .bind(with: self) { owner, value in
                owner.updateLabelCount(count: value, uilabel: owner.followersLabel, text: "팔로워")
            }
            .disposed(by: disposeBag)
        
        output.followingCount
            .bind(with: self) { owner, value in
                owner.updateLabelCount(count: value, uilabel: owner.followingLabel, text: "팔로잉")
            }
            .disposed(by: disposeBag)
        
        output.profileImageData
            .map { UIImage(data: $0) }
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        productList
            .bind(to: productForSaleTableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { row, element, cell in
                cell.selectionStyle = .none
                cell.cellConfig(withCommonPost: element)
            }
            .disposed(by: disposeBag)
        
        productList
            .bind(with: self) { owner, value in
                owner.updateLabelCount(count: value.count, uilabel: owner.productsLabel, text: "판매 상품")
            }
            .disposed(by: disposeBag)
        
        feedList
            .bind(to: feedCollectionView.rx.items(cellIdentifier: FeedCollectionViewCell.identifier, cellType: FeedCollectionViewCell.self)) { row, element, cell in
                if let path = element.files.first {
                    fetchFeedCellImage.accept((row, path))
                }
            }
            .disposed(by: disposeBag)
        
        feedList
            .bind(with: self) { owner, value in
                owner.updateLabelCount(count: value.count, uilabel: owner.feedsLabel, text: "피드")
            }
            .disposed(by: disposeBag)
        
        output.fetchFeedCellImage
            .bind(with: self) { owner, value in
                if let cell = owner.feedCollectionView.cellForItem(at: IndexPath(row: value.0, section: 0)) as? FeedCollectionViewCell {
                    cell.imageView.image = UIImage(data: value.1)
                }
            }
            .disposed(by: disposeBag)
        
        output.buyProducts
            .bind(to: productForBuyTableView.rx.items(cellIdentifier: ProductBuyTableViewCell.identifier, cellType: ProductBuyTableViewCell.self)) { row, element, cell in
                cell.cellConfig(data: element)
                
                if let firstImagePath = element.files.first {
                    fetchBuyCellImage.accept((row, firstImagePath))
                }
            }
            .disposed(by: disposeBag)
        
        output.fetchBuyCellImage
            .bind(with: self) { owner, value in
                if let cell = owner.productForBuyTableView.cellForRow(at: IndexPath(row: value.0, section: 0)) as?  ProductBuyTableViewCell {
                    cell.productImageView.image = UIImage(data: value.1)
                }
            }
            .disposed(by: disposeBag)
        
        output.segmentControlIndexChange
            .bind(with: self) { owner, _ in
                if owner.segmentControl.selectedSegmentIndex == 0 {
                    owner.feedCollectionView.isHidden = false
                    owner.productForBuyTableView.isHidden = true
                    owner.productForSaleTableView.isHidden = true
                }
                if owner.segmentControl.selectedSegmentIndex == 1 {
                    owner.feedCollectionView.isHidden = true
                    owner.productForBuyTableView.isHidden = true
                    owner.productForSaleTableView.isHidden = false
                }
                if owner.segmentControl.selectedSegmentIndex == 2 {
                    owner.feedCollectionView.isHidden = true
                    owner.productForBuyTableView.isHidden = false
                    owner.productForSaleTableView.isHidden = true
                }
            }
            .disposed(by: disposeBag)
        
        feedCollectionView.rx.observe(CGSize.self , "contentSize")
            .bind(with: self) { owner, size in
                owner.feedCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(size?.height ?? 0.0)
                }
            }
            .disposed(by: disposeBag)
        
        productForSaleTableView.rx.observe(CGSize.self, "contentSize")
            .bind(with: self) { owner, size in
                owner.productForSaleTableView.snp.updateConstraints { make in
                    make.height.equalTo(size?.height ?? 0.0)
                }
            }
            .disposed(by: disposeBag)
        
        productForBuyTableView.rx.observe(CGSize.self, "contentSize")
            .bind(with: self) { owner, size in
                owner.productForBuyTableView.snp.updateConstraints { make in
                    make.height.equalTo(size?.height ?? 0.0)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        
        
        
        output.logoutMenuTapped
            .bind(with: self) { owner, _ in
                owner.showMenuButtonTapAlert(title: "로그아웃", message: "로그아웃 하시겠습니까?", buttonTitle: "로그아웃", buttonStyle: .default) { logoutAction in
                    logoutAlertButtonTapped.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        output.executeLogout
            .bind(with: self) { owner, _ in
                owner.setRootViewController(UINavigationController(rootViewController: LoginViewController()))
            }
            .disposed(by: disposeBag)
        
        output.withdrawalMenuTapped
            .bind(with: self) { owner, _ in
                //탈퇴 얼럿
                owner.showToast(message: "탈퇴는 관리자에게 문의 바랍니다", position: .center)
            }
            .disposed(by: disposeBag)
            
        output.viewType
            .bind(with: self) { owner, value in
                switch value {
                case .loginUser:
                    owner.updateEditFollowButtonAppearance(isCurrentLoginUser: true, isFollow: false)
                case .notLoginUser:
                    owner.updateEditFollowButtonAppearance(isCurrentLoginUser: false, isFollow: false)
                }
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
        
        fetchUserProfile.accept(())
    }
    
    override func setupNavi() {
        let title = NavigationTitleLabel(text: "프로필")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.title = ""
    }
    
    private func setupMenuButton() {
        let menu = UIMenu(title: "메뉴", children: [
            UIAction(title: "로그아웃", image: UIImage(systemName: "power")) { [weak self] _ in
                self?.logoutMenuTapped.accept(())
            },
            UIAction(title: "탈퇴하기", image: UIImage(systemName: "person.badge.minus"), attributes: .destructive) { [weak self] _ in
                self?.withdrawalMenuTapped.accept(())
            }
        ])
        menuButton.menu = menu
    }
    
    override func configureHierarchy() {
        view.addSubviews(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(topBackView)
        containerView.addSubview(bottomBackView)
        
        topBackView.addSubviews(
            profileImageView,
            nicknameLabel,
            birthdayButton,
            countInfoStackView,
            editAndFollowButton
        )
        
        bottomBackView.addSubviews(
            segmentControl,
            contentStackView
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
        
        topBackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalTo(view.frame.size.width)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(144)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        birthdayButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        countInfoStackView.snp.makeConstraints { make in
            make.top.equalTo(birthdayButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
        
        editAndFollowButton.snp.makeConstraints { make in
            make.top.equalTo(countInfoStackView.snp.bottom).offset(10)
            make.leading.equalTo(countInfoStackView)
            make.trailing.equalTo(countInfoStackView)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(10)
        }
        
        bottomBackView.snp.makeConstraints { make in
            make.top.equalTo(topBackView.snp.bottom).offset(10)
            make.width.equalTo(view.frame.size.width)
            make.bottom.equalToSuperview()
        }
        
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(editAndFollowButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
        containerView.backgroundColor = .systemGray5
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
    }
    
    //MARK: - Methods
    
    private func updateEditFollowButtonAppearance(isCurrentLoginUser: Bool, isFollow: Bool) {
        if isCurrentLoginUser {
            editAndFollowButton.setTitle("프로필 편집", for: .normal)
            editAndFollowButton.backgroundColor = .white
            editAndFollowButton.tintColor = .black
        } else {
            
            if isFollow {
                editAndFollowButton.setTitle("언팔로우", for: .normal)
                editAndFollowButton.backgroundColor = .white
                editAndFollowButton.tintColor = .black
            } else {
                editAndFollowButton.setTitle("팔로우", for: .normal)
                editAndFollowButton.backgroundColor = Constant.Color.brandColor
                editAndFollowButton.tintColor = Constant.Color.Button.titleColor
            }
        }
    }
    
    private func updateLabelCount(count: Int, uilabel: UILabel, text: String) {
        let attributedText = NSMutableAttributedString(string: "\(count)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        uilabel.attributedText = attributedText
    }
    
    private func showMenuButtonTapAlert(title: String, message: String, buttonTitle: String, buttonStyle: UIAlertAction.Style, action: @escaping ((UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: buttonTitle, style: buttonStyle, handler: action))
        present(alert, animated: true)
    }
}
