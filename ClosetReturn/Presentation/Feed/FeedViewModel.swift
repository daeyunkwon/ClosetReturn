//
//  FeedViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var next_cursor = ""
    private var limit = "15"
    
    private var feeds: [FeedPost] = []
    
    //MARK: - Inputs
    
    struct Input {
        let firstFetch: PublishRelay<Void>
        let fetchCellImage: PublishRelay<(Int, String)>
        let cellWillDisplay: PublishRelay<IndexPath>
        let startRefresh: ControlEvent<()>
        let newButtonTapped: ControlEvent<Void>
        let modelSelected: ControlEvent<FeedPost>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let feedList: PublishRelay<[FeedPost]>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let cellImageData: PublishRelay<(Int, Data)>
        let endRefresh: PublishRelay<Void>
        let newButtonTapped: ControlEvent<Void>
        let modelSelected: ControlEvent<FeedPost>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let feedList = PublishRelay<[FeedPost]>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let cellImageData = PublishRelay<(Int, Data)>()
        let endRefresh = PublishRelay<Void>()
        
        
        func fetchFeed(next_cursor: String, completionHandler: @escaping () -> Void) {
            NetworkManager.shared.performRequest(api: .posts(next: next_cursor, limit: self.limit, product_id: APIKey.feedID), model: FeedPostData.self)
                .asObservable()
                .bind(with: self) { owner, result in
                    switch result {
                    case .success(let data):
                        if next_cursor == "" {
                            owner.feeds = data.data
                        } else {
                            owner.feeds.append(contentsOf: data.data)
                        }
                        
                        owner.next_cursor = data.next_cursor
                        feedList.accept(owner.feeds)
                        completionHandler()
                        
                    case .failure(let error):
                        networkError.accept((error, RouterType.posts))
                        completionHandler()
                    }
                }
                .disposed(by: self.disposeBag)
        }
        
        
        input.firstFetch
            .bind(with: self) { owner, _ in
                fetchFeed(next_cursor: "") { }
            }
            .disposed(by: disposeBag)
        
        input.fetchCellImage
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value.1) { result in
                    switch result {
                    case .success(let data):
                        cellImageData.accept((value.0, data))
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.cellWillDisplay
            .bind(with: self) { owner, indexPath in
                if indexPath.row == owner.feeds.count - 1 {
                    if owner.next_cursor != "0" {
                        fetchFeed(next_cursor: owner.next_cursor) { }
                    } else {
                        print("DEBUG: 더 이상 피드가 존재하지 않으므로 fetch 미실행")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.startRefresh
            .bind(with: self) { owner, _ in
                fetchFeed(next_cursor: "") {
                    endRefresh.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            feedList: feedList,
            networkError: networkError,
            cellImageData: cellImageData,
            endRefresh: endRefresh,
            newButtonTapped: input.newButtonTapped,
            modelSelected: input.modelSelected
        )
    }
}
