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
    }
    
    //MARK: - Outputs
    
    struct Output {
        let productPosts: BehaviorSubject<[ProductPost]>
        
        
        let networkError: PublishRelay<NetworkError>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let productPosts = BehaviorSubject<[ProductPost]>(value: self.productPosts)
        let networkError = PublishRelay<NetworkError>()
        
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
                        networkError.accept(error)
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
        
        
        return Output(
            productPosts: productPosts,
            networkError: networkError
        )
    }
}
