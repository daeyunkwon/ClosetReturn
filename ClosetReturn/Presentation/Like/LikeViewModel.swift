//
//  LikeViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/26/24.
//

import Foundation

import RxSwift
import RxCocoa

final class LikeViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var productNext = ""
    private var feedNext = ""
    
    private var productPosts: [ProductPost] = []
    private var feedPosts: [FeedPost] = []
    
    
    //MARK: - Inputs
    
    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let selectedSegmentIndex: ControlProperty<Int>
        let cellLikeButtonTapped: PublishRelay<(String, Bool, Int)>
        let productCellWillDisplay: ControlEvent<WillDisplayCellEvent>
        let productCellModelSelected: ControlEvent<ProductPost>
        let fetchReloadToProduct: PublishRelay<Void>
        let startRefreshToProduct: ControlEvent<Void>
        let fetchFeedCellImage: PublishRelay<(String, Int)>
        let fetchReloadToFeed: PublishRelay<Void>
        let startRefreshToFeed: ControlEvent<Void>
        let feedCellWillDisplay: PublishRelay<IndexPath>
        let modelSelectedToFeed: ControlEvent<FeedPost>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let selectedSegmentIndex: ControlProperty<Int>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let productList: PublishRelay<[ProductPost]>
        let feedList: PublishRelay<[FeedPost]>
        let likeStatus: PublishRelay<(Bool, Int)>
        let productCellModelSelected: ControlEvent<ProductPost>
        let endRefreshToProduct: PublishRelay<Void>
        let feedCellImage: PublishRelay<(Data, Int)>
        let endRefreshToFeed: PublishRelay<Void>
        let modelSelectedToFeed: ControlEvent<FeedPost>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let productList = PublishRelay<[ProductPost]>()
        let feedList = PublishRelay<[FeedPost]>()
        let likeStatus = PublishRelay<(Bool, Int)>()
        let endRefreshToProduct = PublishRelay<Void>()
        let feedCellImage = PublishRelay<(Data, Int)>()
        let endRefreshToFeed = PublishRelay<Void>()
        
        func fetchProductLike(next_cursor: String) {
            NetworkManager.shared.performRequest(api: .likeFetch(next: next_cursor, limit: "7"), model: ProductPostData.self)
                .asObservable()
                .bind { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let data):
                        self.productPosts.append(contentsOf: data.data)
                        self.productNext = data.next_cursor
                        productList.accept(self.productPosts)
                        
                        data.data.forEach { post in
                            if post.likes.contains(UserDefaultsManager.shared.userID) {
                                UserDefaultsManager.shared.likeProducts[post.post_id] = true
                            } else {
                                UserDefaultsManager.shared.likeProducts.removeValue(forKey: post.post_id)
                            }
                        }
                    case .failure(let error):
                        networkError.accept((error, RouterType.likeFetch))
                    }
                }
                .disposed(by: self.disposeBag)
        }
        
        func fetchFeedLike(next_cursor: String) {
            NetworkManager.shared.performRequest(api: .like2Fetch(next: next_cursor, limit: "15"), model: FeedPostData.self)
                .asObservable()
                .bind { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let data):
                        self.feedPosts.append(contentsOf: data.data)
                        self.feedNext = data.next_cursor
                        feedList.accept(self.feedPosts)
                        
                        data.data.forEach { feedPost in
                            if feedPost.likes2.contains(UserDefaultsManager.shared.userID) {
                                UserDefaultsManager.shared.likeFeed[feedPost.post_id] = true
                            } else {
                                UserDefaultsManager.shared.likeFeed.removeValue(forKey: feedPost.post_id)
                            }
                        }
                    case .failure(let error):
                        networkError.accept((error, RouterType.likeFetch))
                    }
                }
                .disposed(by: self.disposeBag)
        }
        
        input.fetchFeedCellImage
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value.0) { result in
                    switch result {
                    case .success(let data):
                        feedCellImage.accept((data, value.1))
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                fetchFeedLike(next_cursor: "") //초기에는 피드 데이터도 구성해주기
            }
            .disposed(by: disposeBag)
        
        input.cellLikeButtonTapped
            .bind(with: self) { owner, value in
                NetworkManager.shared.performRequest(api: .like(postID: value.0, isLike: value.1), model: [String: Bool].self)
                    .asObservable()
                    .subscribe(with: self) { owner, result in
                        switch result {
                        case .success(_):
                            if value.1 {
                                UserDefaultsManager.shared.likeProducts[value.0] = value.1
                            } else {
                                UserDefaultsManager.shared.likeProducts.removeValue(forKey: value.0)
                            }
                            likeStatus.accept((value.1, value.2))
                            
                        case .failure(let error):
                            print("뷰모델에서 전달받은 에러: \(error)")
                            networkError.accept((error, RouterType.like))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.productCellWillDisplay
            .bind(with: self) { owner, value in
                if value.indexPath.row == owner.productPosts.count - 1 {
                    if owner.productNext != "0" {
                        fetchProductLike(next_cursor: owner.productNext)
                    } else {
                        print("DEBUG: 더 이상의 포스트가 존재하지 않으므로 fetch 미실행")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.fetchReloadToProduct
            .bind(with: self) { owner, _ in
                owner.productPosts = []
                fetchProductLike(next_cursor: "")
            }
            .disposed(by: disposeBag)
        
        input.startRefreshToProduct
            .bind(with: self) { owner, _ in
                owner.productPosts = []
                fetchProductLike(next_cursor: "")
                endRefreshToProduct.accept(())
            }
            .disposed(by: disposeBag)
        
        input.startRefreshToFeed
            .bind(with: self) { owner, _ in
                owner.feedPosts = []
                fetchFeedLike(next_cursor: "")
                endRefreshToFeed.accept(())
            }
            .disposed(by: disposeBag)
        
        input.fetchReloadToFeed
            .bind(with: self) { owner, _ in
                owner.feedPosts = []
                fetchFeedLike(next_cursor: "")
            }
            .disposed(by: disposeBag)
        
        input.feedCellWillDisplay
            .bind(with: self) { owner, indexPath in
                if indexPath.row == owner.feedPosts.count - 1 {
                    if owner.feedNext != "0" {
                        fetchFeedLike(next_cursor: owner.feedNext)
                    } else {
                        print("DEBUG: 더 이상 피드가 존재하지 않으므로 fetch 미실행")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            selectedSegmentIndex: input.selectedSegmentIndex,
            networkError: networkError,
            productList: productList,
            feedList: feedList,
            likeStatus: likeStatus,
            productCellModelSelected: input.productCellModelSelected,
            endRefreshToProduct: endRefreshToProduct,
            feedCellImage: feedCellImage,
            endRefreshToFeed: endRefreshToFeed,
            modelSelectedToFeed: input.modelSelectedToFeed
        )
    }
}
