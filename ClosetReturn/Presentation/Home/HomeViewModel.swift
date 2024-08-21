//
//  HomeViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import Foundation

import RxSwift
import RxCocoa

final class HomeViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var productPosts: [ProductPost] = []
    private var nextCursor: String = ""
    
    //MARK: - Inputs
    
    struct Input {
        let cellWillDisplay: ControlEvent<WillDisplayCellEvent>
        let cellLikeButtonTap: PublishRelay<(String, Bool, Int)>
        let cellTapped: ControlEvent<ProductPost>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let productPosts: BehaviorSubject<[ProductPost]>
        let likeStatus: PublishRelay<(Bool, Int)>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let cellTapped: ControlEvent<ProductPost>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let productPosts = BehaviorSubject<[ProductPost]>(value: self.productPosts)
        let likeStatus = PublishRelay<(Bool, Int)>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        
        func fetchPosts(nextCursor: String) {
            NetworkManager.shared.performRequest(api: .posts(next: nextCursor, limit: "7", product_id: APIKey.productID), model: ProductPostData.self)
                .asObservable()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let value):
                        owner.productPosts.append(contentsOf: value.data)
                        owner.nextCursor = value.next_cursor
                        productPosts.onNext(owner.productPosts)
                    case .failure(let error):
                        networkError.accept((error, RouterType.posts))
                    }
                }
                .disposed(by: disposeBag)
        }
        
        fetchPosts(nextCursor: "")
        
        input.cellWillDisplay
            .bind(with: self) { owner, value in
                if value.indexPath.row == owner.productPosts.count - 1 {
                    if owner.nextCursor != "0" {
                        fetchPosts(nextCursor: owner.nextCursor)
                    } else {
                        print("DEBUG: 더 이상의 포스트가 존재하지 않으므로 fetch 미실행")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.cellLikeButtonTap
            .bind(with: self) { owner, value in
                NetworkManager.shared.performRequest(api: .like(postID: value.0, isLike: value.1), model: [String: Bool].self)
                    .asObservable()
                    .subscribe(with: self) { owner, result in
                        
                        switch result {
                        case .success(_):
                            if value.1 {
                                UserDefaultsManager.shared.likeProducts[value.0] = value.1
                                print(UserDefaultsManager.shared.likeProducts)
                            } else {
                                UserDefaultsManager.shared.likeProducts.removeValue(forKey: value.0)
                                print(UserDefaultsManager.shared.likeProducts)
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
            
        
        return Output(
            productPosts: productPosts,
            likeStatus: likeStatus,
            networkError: networkError,
            cellTapped: input.cellTapped
        )
    }
}
