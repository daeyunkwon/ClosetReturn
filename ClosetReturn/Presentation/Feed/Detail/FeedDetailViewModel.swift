//
//  FeedDetailViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/26/24.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedDetailViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var postID: String
    private var feedPost: FeedPost?
    private var imageDatas: [Data] = []
    
    var postDeleteSucceed: () -> Void = { }
    
    //MARK: - Init
    
    init(postID: String) {
        self.postID = postID
    }
    
    //MARK: - Inputs
    
    struct Input {
        let fetch: PublishRelay<Void>
        let likeButtonTapped: ControlEvent<Void>
        let editButtonTapped: PublishRelay<Void>
        let deleteButtonTapped: PublishRelay<Void>
        let alertDeleteButtonTapped: PublishRelay<Void>
        let commentButtonTapped: ControlEvent<Void>
        let profileTapped: PublishRelay<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let profileImage: PublishRelay<Data>
        let nickname: PublishRelay<String>
        let feedImages: PublishRelay<[Data]>
        let likeCount: PublishRelay<Int>
        let commentCount: PublishRelay<Int>
        let content: PublishRelay<String>
        let date: PublishRelay<String>
        let like: PublishRelay<Bool>
        let hideMenuButton: PublishRelay<Bool>
        let editButtonTapped: PublishRelay<(String, String, [Data])>
        let deleteButtonTapped: PublishRelay<Void>
        let deleteSucceed: PublishRelay<Void>
        let commentButtonTapped: PublishRelay<(FeedPost)>
        let goToProfile: PublishRelay<(String)>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let resultData = PublishRelay<FeedPost>()
        
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let profileImage = PublishRelay<Data>()
        let nickname = PublishRelay<String>()
        let feedImages = PublishRelay<[Data]>()
        let likeCount = PublishRelay<Int>()
        let commentCount = PublishRelay<Int>()
        let content = PublishRelay<String>()
        let date = PublishRelay<String>()
        let like = PublishRelay<Bool>()
        let hideMenuButton = PublishRelay<Bool>()
        let editButtonTapped = PublishRelay<(String, String, [Data])>()
        let deleteSucceed = PublishRelay<Void>()
        let commentButtonTapped = PublishRelay<(FeedPost)>()
        let goToProfile = PublishRelay<(String)>()
        
        
        input.fetch
            .bind(with: self) { owner, _ in
                NetworkManager.shared.performRequest(api: .postDetail(postID: owner.postID), model: FeedPost.self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            owner.feedPost = data
                            
                            if let feed = owner.feedPost {
                                resultData.accept(feed)
                            }
                            
                            if UserDefaultsManager.shared.likeFeed[data.post_id] != nil {
                                like.accept(true)
                            } else {
                                like.accept(false)
                            }
                            
                        case .failure(let error):
                            networkError.accept((error, RouterType.postDetail))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        let feed = resultData.share()
        
        feed
            .map { $0.creator.nick }
            .bind(with: self) { owner, value in
                nickname.accept(value)
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.likes2.count }
            .bind(with: self) { owner, value in
                likeCount.accept(value)
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.comments.count }
            .bind(with: self) { owner, value in
                commentCount.accept(value)
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.content }
            .bind(with: self) { owner, value in
                content.accept(value)
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.createDateString }
            .bind(with: self) { owner, value in
                date.accept(value)
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.creator.profileImage }
            .compactMap { $0 }
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value) { result in
                    switch result {
                    case .success(let profile):
                        profileImage.accept(profile)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.files }
            .filter { !$0.isEmpty }
            .bind(with: self) { owner, list in
                
                var temp: [Data] = []
                let group = DispatchGroup()
                
                for path in list {
                    
                    group.enter()
                    NetworkManager.shared.fetchImageData(imagePath: path) { result in
                        switch result {
                        case .success(let data):
                            temp.append(data)
                            group.leave()
                        case .failure(let error):
                            print(error)
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    owner.imageDatas = temp
                    feedImages.accept(temp)
                }
            }
            .disposed(by: disposeBag)
        
        feed
            .map { $0.creator.user_id }
            .bind { value in
                if UserDefaultsManager.shared.userID == value {
                    hideMenuButton.accept(false)
                } else {
                    hideMenuButton.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.likeButtonTapped
            .bind(with: self) { owner, _ in
                
                var newValue: Bool
                if UserDefaultsManager.shared.likeFeed[owner.postID] != nil {
                    newValue = false
                } else {
                    newValue = true
                }
                
                NetworkManager.shared.performRequest(api: .like2(postID: owner.postID, isLike: newValue), model: [String: Bool].self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            if let changedValue = data.first?.value {
                                let count = owner.feedPost?.likes2.count ?? 0
                                
                                if changedValue {
                                    UserDefaultsManager.shared.likeFeed[owner.postID] = true
                                    like.accept(true)
                                    likeCount.accept(count + 1)
                                } else {
                                    UserDefaultsManager.shared.likeFeed.removeValue(forKey: owner.postID)
                                    like.accept(false)
                                    if count == 0 {
                                        likeCount.accept(count)
                                    } else {
                                        likeCount.accept(count - 1)
                                    }
                                    
                                }
                            }
                        case .failure(let error):
                            networkError.accept((error, RouterType.like2))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.editButtonTapped
            .bind(with: self) { owner, _ in
                guard let data = owner.feedPost else { return }
                editButtonTapped.accept((data.post_id, data.content, owner.imageDatas))
            }
            .disposed(by: disposeBag)
        
        input.alertDeleteButtonTapped
            .bind(with: self) { owner, _ in
                NetworkManager.shared.performDeleteReuqest(api: .postDelete(postID: owner.postID))
                    .asObservable()
                    .bind { result in
                        switch result {
                        case .success(_):
                            deleteSucceed.accept(())
                        case .failure(let error):
                            networkError.accept((error, RouterType.postDelete))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.commentButtonTapped
            .bind(with: self) { owner, _ in
                guard let data = owner.feedPost else { return }
                commentButtonTapped.accept(data)
            }
            .disposed(by: disposeBag)
            
        input.profileTapped
            .bind(with: self) { owner, _ in
                if let userID = owner.feedPost?.creator.user_id {
                    goToProfile.accept(userID)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(
            networkError: networkError,
            profileImage: profileImage,
            nickname: nickname,
            feedImages: feedImages,
            likeCount: likeCount,
            commentCount: commentCount,
            content: content,
            date: date,
            like: like,
            hideMenuButton: hideMenuButton,
            editButtonTapped: editButtonTapped,
            deleteButtonTapped: input.deleteButtonTapped,
            deleteSucceed: deleteSucceed,
            commentButtonTapped: commentButtonTapped,
            goToProfile: goToProfile
        )
    }
}
