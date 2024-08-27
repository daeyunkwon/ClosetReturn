//
//  LikeViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/26/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class LikeViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = LikeViewModel()
    
    private let fetchReloadToProduct = PublishRelay<Void>()
    private let fetchReloadToFeed = PublishRelay<Void>()
    
    //MARK: - UI Components
    
    private let segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "상품", at: 0, animated: true)
        segment.insertSegment(withTitle: "피드", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)], for: .selected)
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        return segment
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let productRefreshControl = UIRefreshControl()
    private let feedRefreshControl = UIRefreshControl()
    
    private lazy var productTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.identifier)
        tv.rowHeight = 210
        tv.refreshControl = productRefreshControl
        tv.isHidden = false
        return tv
    }()
    
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
        cv.isHidden = true
        return cv
    }()
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            fetchReloadToProduct.accept(())
        case 1:
            fetchReloadToFeed.accept(())
        default: break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let viewDidLoad = PublishRelay<Void>()
        let likeButtonTap = PublishRelay<(String, Bool, Int)>()
        let fetchFeedCellImage = PublishRelay<(String, Int)>()
        let fetchFeedNextPage = PublishRelay<IndexPath>()
        
        let input = LikeViewModel.Input(
            viewDidLoad: viewDidLoad,
            selectedSegmentIndex: segmentControl.rx.selectedSegmentIndex,
            cellLikeButtonTapped: likeButtonTap,
            productCellWillDisplay: productTableView.rx.willDisplayCell,
            productCellModelSelected: productTableView.rx.modelSelected(ProductPost.self),
            fetchReloadToProduct: fetchReloadToProduct,
            startRefreshToProduct: productRefreshControl.rx.controlEvent(.valueChanged),
            fetchFeedCellImage: fetchFeedCellImage,
            fetchReloadToFeed: fetchReloadToFeed,
            startRefreshToFeed: feedRefreshControl.rx.controlEvent(.valueChanged),
            feedCellWillDisplay: fetchFeedNextPage,
            modelSelectedToFeed: feedCollectionView.rx.modelSelected(FeedPost.self)
        )
        let output = viewModel.transform(input: input)
        
        feedCollectionView.rx.willDisplayCell
            .bind(with: self) { owner, value in
                fetchFeedNextPage.accept(value.1)
            }
            .disposed(by: disposeBag)
        
        output.selectedSegmentIndex
            .bind(with: self) { owner, index in
                owner.updateUnderLineXPosition()
                
                if index == 0 {
                    owner.productTableView.isHidden = false
                    owner.feedCollectionView.isHidden = true
                } else {
                    owner.productTableView.isHidden = true
                    owner.feedCollectionView.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        
        output.productList
            .bind(to: productTableView.rx.items(cellIdentifier: HomeTableViewCell.identifier, cellType: HomeTableViewCell.self)) { row, element, cell in
                cell.cellConfig(data: element)
                cell.selectionStyle = .none
                
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        cell.likeButton.isUserInteractionEnabled = false
                        
                        var newValue: Bool
                        
                        if UserDefaultsManager.shared.likeProducts[element.post_id] != nil {
                            newValue = false
                        } else {
                            newValue = true
                        }
                        
                        likeButtonTap.accept((element.post_id, newValue, row))
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.likeStatus
            .bind(with: self) { owner, value in
                if let cell = owner.productTableView.cellForRow(at: IndexPath(row: value.1, section: 0)) as? HomeTableViewCell {
                    cell.updateAppearanceLikeButton(isLiked: value.0)
                    cell.likeButton.isUserInteractionEnabled = true
                }
            }
            .disposed(by: disposeBag)
        
        output.productCellModelSelected
            .bind(with: self) { owner, data in
                let vm = ProductDetailViewModel()
                vm.postDeleteSucceed = { [weak self] in
                    self?.showToast(message: "해당 상품이 삭제되었습니다", position: .bottom)
                    self?.fetchReloadToProduct.accept(())
                }
                vm.postID = data.post_id
                let vc = ProductDetailViewController(viewModel: vm)
                owner.pushViewController(vc)
            }
            .disposed(by: disposeBag)
        
        output.endRefreshToProduct
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    owner.productRefreshControl.endRefreshing()
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        
        output.feedList
            .bind(to: feedCollectionView.rx.items(cellIdentifier: FeedCollectionViewCell.identifier, cellType: FeedCollectionViewCell.self)) { row, element, cell in
                if let path = element.files.first {
                    fetchFeedCellImage.accept((path, row))
                }
            }
            .disposed(by: disposeBag)
        
        output.feedCellImage
            .bind(with: self) { owner, value in
                if let cell = owner.feedCollectionView.cellForItem(at: IndexPath(row: value.1, section: 0)) as? FeedCollectionViewCell {
                    cell.imageView.image = UIImage(data: value.0)
                }
            }
            .disposed(by: disposeBag)
        
        output.endRefreshToFeed
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    owner.feedRefreshControl.endRefreshing()
                }
            }
            .disposed(by: disposeBag)
        
        output.modelSelectedToFeed
            .bind(with: self) { owner, feedPost in
                let vm = FeedDetailViewModel(postID: feedPost.post_id)
                vm.postDeleteSucceed = {
                    owner.showToast(message: "피드가 삭제되었습니다", position: .bottom)
                    //owner.fetchReloadToFeed.accept(())
                    //owner.segmentControl.selectedSegmentIndex = 1
                    owner.updateUnderLineXPosition()
                }
                let vc = FeedDetailViewController(viewModel: vm)
                owner.pushViewController(vc)
            }
            .disposed(by: disposeBag)
        
        
        
        
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
        
        viewDidLoad.accept(())
    }
    
    override func setupNavi() {
        navigationItem.title = ""
        let label = NavigationTitleLabel(text: "좋아요")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
    
    override func configureHierarchy() {
        view.addSubviews(
            segmentControl,
            underLineView,
            productTableView,
            feedCollectionView
        )
    }
    
    override func configureLayout() {
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        underLineView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(10)
            make.leading.equalTo(segmentControl.snp.leading)
            make.width.equalTo(segmentControl.snp.width).dividedBy(2)
            make.height.equalTo(2)
        }
        
        productTableView.snp.makeConstraints { make in
            make.top.equalTo(underLineView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        feedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(underLineView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    //MARK: - Methods
    
    func updateUnderLineXPosition() {
        let halfWidth = segmentControl.frame.width / 2
        let xPosition = segmentControl.frame.origin.x + (halfWidth * CGFloat(segmentControl.selectedSegmentIndex))
        
        UIView.animate(withDuration: 0.2) {
            self.underLineView.frame.origin.x = xPosition
        }
        
        print("선택 세그먼트: \(segmentControl.selectedSegmentIndex)")
        print("width: \(segmentControl.frame.width)")
        print("xPosition: \(xPosition)")
    }
}
