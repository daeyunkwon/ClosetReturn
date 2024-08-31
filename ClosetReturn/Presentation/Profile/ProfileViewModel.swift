//
//  ProfileViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/28/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ProfileViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    enum ViewType {
        case loginUser
        case notLoginUser
    }
    private var viewType: ViewType
    private var userID: String
    
    private var followerCount: Int = 0
    private var productPosts: [CommonPost] = []
    private var feedPosts: [CommonPost] = []
    private var buyProducts: [ProductPost] = []
    
    //MARK: - Init
    
    init(viewType: ViewType, userID: String) {
        self.viewType = viewType
        self.userID = userID
    }
    
    //MARK: - Inputs
    
    struct Input {
        let fetchUserProfile: PublishRelay<Void>
        let segmentControlIndexChange: ControlEvent<()>
        let fetchFeedCellImage: PublishRelay<(Int, String)>
        let fetchBuyCellImage: PublishRelay<(Int, String)>
        let logoutMenuTapped: PublishRelay<Void>
        let withdrawalMenuTapped: PublishRelay<Void>
        let logoutAlertButtonTapped: PublishRelay<Void>
        let editAndFollowButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let viewType: BehaviorRelay<(ViewType)>
        let nickname: PublishRelay<String>
        let followerCount: PublishRelay<Int>
        let followingCount: PublishRelay<Int>
        let profileImageData: PublishRelay<Data>
        let productPosts: PublishRelay<[CommonPost]>
        let feedPosts: PublishRelay<[CommonPost]>
        let buyProducts: PublishRelay<[ProductPost]>
        let segmentControlIndexChange: ControlEvent<()>
        let fetchFeedCellImage: PublishRelay<(Int, Data)>
        let fetchBuyCellImage: PublishRelay<(Int, Data)>
        let logoutMenuTapped: PublishRelay<Void>
        let withdrawalMenuTapped: PublishRelay<Void>
        let executeLogout: PublishRelay<Void>
        let executeEdit: PublishRelay<Void>
    }
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let viewType = BehaviorRelay<(ViewType)>(value: self.viewType)
        let nickname = PublishRelay<String>()
        let followerCount = PublishRelay<Int>()
        let followingCount = PublishRelay<Int>()
        let profileImageData = PublishRelay<Data>()
        let productPosts = PublishRelay<[CommonPost]>()
        let feedPosts = PublishRelay<[CommonPost]>()
        let buyProducts = PublishRelay<[ProductPost]>()
        let fetchFeedCellImage = PublishRelay<(Int, Data)>()
        let fetchBuyCellImage = PublishRelay<(Int, Data)>()
        let executeLogout = PublishRelay<Void>()
        let executeEdit = PublishRelay<Void>()
        
        
        input.fetchUserProfile
            .bind(with: self) { owner, _ in
                var userID: String
                switch owner.viewType {
                case .loginUser:
                    userID = UserDefaultsManager.shared.userID
                    owner.userID = userID
                case .notLoginUser:
                    userID = owner.userID
                }
                
                NetworkManager.shared.performRequest(api: .targetUserProfile(userID: userID), model: Profile.self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            
                            if let path = data.profileImage {
                                NetworkManager.shared.fetchImageData(imagePath: path) { result in
                                    switch result {
                                    case .success(let imageData):
                                        profileImageData.accept(imageData)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }
                            
                            nickname.accept(data.nick)
                            owner.followerCount = data.followers.count
                            followerCount.accept(data.followers.count)
                            followingCount.accept(data.following.count)
                            
                            
                            let group = DispatchGroup()
                            owner.productPosts = []
                            owner.feedPosts = []
                            owner.buyProducts = []
                            
                            for postID in data.posts {
                                group.enter()
                                NetworkManager.shared.performRequest(api: .postDetail(postID: postID), model: CommonPost.self)
                                    .asObservable()
                                    .bind(with: self) { owner, result in
                                        switch result {
                                        case .success(let post):
                                            if post.product_id == APIKey.productID {
                                                owner.productPosts.append(post)
                                                group.leave()
                                            } else {
                                                owner.feedPosts.append(post)
                                                group.leave()
                                            }
                                        case .failure(let error):
                                            print("Error: fetch postDetial failed :: ", error)
                                            group.leave()
                                        }
                                    }
                                    .disposed(by: owner.disposeBag)
                            }
                            
                            group.enter()
                            NetworkManager.shared.performRequest(api: .paymentMe, model: PaymentMe.self)
                                .asObservable()
                                .bind(with: self) { owner, result in
                                    switch result {
                                    case .success(let paymentMe):
                                        
                                        for payment in paymentMe.data {
                                            
                                            if let postID = payment.post_id {
                                                group.enter()
                                                NetworkManager.shared.performRequest(api: .postDetail(postID: postID), model: ProductPost.self)
                                                    .asObservable()
                                                    .bind(with: self) { owner, result in
                                                        switch result {
                                                        case .success(let productPost):
                                                            var newProductPostData = productPost
                                                            newProductPostData.setupPaidAt(data: payment.paidAt ?? "NONE")
                                                            owner.buyProducts.append(newProductPostData)
                                                            group.leave()
                                                        case .failure(let error):
                                                            print(error)
                                                            group.leave()
                                                        }
                                                    }
                                                    .disposed(by: owner.disposeBag)
                                            }
                                        }
                                        group.leave()
                                    case .failure(let error):
                                        print("ERROR: paymentMe fetch failed == ", error)
                                        group.leave()
                                    }
                                }
                                .disposed(by: owner.disposeBag)
                            
                            group.notify(queue: .main) {
                                productPosts.accept(owner.productPosts)
                                feedPosts.accept(owner.feedPosts)
                                buyProducts.accept(owner.buyProducts)
                            }
                            
                        case .failure(let error):
                            networkError.accept((error, RouterType.targetUserProfile))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
    
        input.fetchFeedCellImage
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value.1) { result in
                    switch result {
                    case .success(let data):
                        fetchFeedCellImage.accept((value.0, data))
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.fetchBuyCellImage
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value.1) { result in
                    switch result {
                    case .success(let data):
                        fetchBuyCellImage.accept((value.0, data))
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)        
        
        input.logoutAlertButtonTapped
            .bind(with: self) { owner, _ in
                UserDefaultsManager.shared.removeAll {
                    executeLogout.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        input.editAndFollowButtonTapped
            .bind(with: self) { owner, _ in
                switch owner.viewType {
                case .loginUser:
                    executeEdit.accept(())
                case .notLoginUser:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            networkError: networkError,
            viewType: viewType,
            nickname: nickname,
            followerCount: followerCount,
            followingCount: followingCount,
            profileImageData: profileImageData,
            productPosts: productPosts,
            feedPosts: feedPosts,
            buyProducts: buyProducts,
            segmentControlIndexChange: input.segmentControlIndexChange,
            fetchFeedCellImage: fetchFeedCellImage,
            fetchBuyCellImage: fetchBuyCellImage,
            logoutMenuTapped: input.logoutMenuTapped,
            withdrawalMenuTapped: input.withdrawalMenuTapped,
            executeLogout: executeLogout,
            executeEdit: executeEdit
        )
    }
}
