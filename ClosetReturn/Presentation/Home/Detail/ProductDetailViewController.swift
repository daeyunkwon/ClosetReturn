//
//  ProductDetailViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/21/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProductDetailViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let viewModel: any BaseViewModel
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    
    init(viewModel: any BaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let scrollView = UIScrollView()
    
    private let scrollContainerView = UIView()
    
    private lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.size.width, height: 480)
        layout.sectionInset = .init(top: 0, left: 0, bottom: 10, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.register(ProductDetailCollectionViewCell.self, forCellWithReuseIdentifier: ProductDetailCollectionViewCell.identifier)
        cv.backgroundColor = .lightGray
        return cv
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 22
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryTitleFont
        label.textColor = Constant.Color.Text.titleColor
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
        label.textColor = Constant.Color.Text.titleColor
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
        label.font = Constant.Font.secondaryBoldFont
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryBoldFont
        return label
    }()
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryBoldFont
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.secondaryBoldFont
        return label
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
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
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        if let viewModel = viewModel as? ProductDetailViewModel {
            
            
            
            
        }
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainerView)
        scrollContainerView.addSubviews(
            collectionView,
            profileImageView,
            nicknameLabel,
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
            contentTextView
        )
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubviews(
            likeButton,
            commentButton,
            buyButton
        )
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollContainerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
            make.verticalEdges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(500)
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
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
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.bottom).inset(30)
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
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
