//
//  FeedViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class FeedViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel = FeedViewModel()
    
    //MARK: - UI Components
    
    private let refreshControl = UIRefreshControl()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.size.width / 3 - 2, height: view.frame.size.width / 3)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.sectionInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(FeedCollectionViewCell.self, forCellWithReuseIdentifier: FeedCollectionViewCell.identifier)
        cv.refreshControl = refreshControl
        return cv
    }()
    
    private let newButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.square")?.applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 20, weight: .semibold))), for: .normal)
        btn.tintColor = Constant.Color.brandColor
        return btn
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let fetch = PublishRelay<Void>()
        let fetchCellImage = PublishRelay<(Int, String)>()
        let fetchNextPage = PublishRelay<IndexPath>()
        
        let input = FeedViewModel.Input(
            firstFetch: fetch,
            fetchCellImage: fetchCellImage,
            cellWillDisplay: fetchNextPage,
            startRefresh: refreshControl.rx.controlEvent(.valueChanged),
            newButtonTapped: newButton.rx.tap,
            modelSelected: collectionView.rx.modelSelected(FeedPost.self)
            
        )
        let output = viewModel.transform(
            input: input
        )
        
        fetch.accept(()) //최초 fetch 작업 실행
        
        collectionView.rx.willDisplayCell
            .bind(with: self) { owner, value in
                fetchNextPage.accept(value.1)
            }
            .disposed(by: disposeBag)
        
        output.feedList
            .bind(to: collectionView.rx.items(cellIdentifier: FeedCollectionViewCell.identifier, cellType: FeedCollectionViewCell.self)) { row, element, cell in
                
                if let path = element.files.first {
                    fetchCellImage.accept((row, path))
                }
            }
            .disposed(by: disposeBag)
        
        output.cellImageData
            .bind(with: self) { owner, value in
                if let cell = owner.collectionView.cellForItem(at: IndexPath(row: value.0, section: 0)) as? FeedCollectionViewCell {
                    cell.imageView.image = UIImage(data: value.1)
                }
            }
            .disposed(by: disposeBag)
        
        output.endRefresh
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    owner.refreshControl.endRefreshing()
                }
            }
            .disposed(by: disposeBag)
        
        output.newButtonTapped
            .bind(with: self) { owner, _ in
                let vm = FeedEditViewModel(viewType: .new)
                vm.postUploadSucceed = { [weak self] in
                    
                    self?.showToast(message: "피드가 등록되었습니다", position: .bottom)
                }
                let vc = FeedEditViewController(viewModel: vm)
                let navi = UINavigationController(rootViewController: vc)
                navi.modalPresentationStyle = .fullScreen
                owner.present(navi, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.modelSelected
            .bind(with: self) { owner, feedPost in
                let vm = FeedDetailViewModel(postID: feedPost.post_id)
                vm.postDeleteSucceed = {
                    owner.showToast(message: "피드가 삭제되었습니다", position: .bottom)
                    fetch.accept(())
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
    }
    
    override func setupNavi() {
        navigationItem.title = ""
        let label = NavigationTitleLabel(text: "피드")
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newButton)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
