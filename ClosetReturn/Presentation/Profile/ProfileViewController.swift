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
    private let viewModel = ProfileViewModel()
    
    
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
        label.font = Constant.Font.bodyBoldFont
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
        tv.rowHeight = 180
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
        tv.rowHeight = 180
        tv.refreshControl = productForBuyRefreshControl
        tv.isHidden = true
        tv.isScrollEnabled = false
        return tv
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
    }
    
    override func setupNavi() {
        let title = NavigationTitleLabel(text: "프로필")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: title)
        navigationItem.title = ""
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
}
