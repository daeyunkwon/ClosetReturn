//
//  CommentViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import Foundation

import RxSwift
import RxCocoa

final class CommentViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var postID: String
    private var comments: [Comment]
    private var content: String = ""
    
    var newCommentUpload: () -> Void = { }
    
    //MARK: - Init
    
    init(postID: String, comments: [Comment]) {
        self.postID = postID
        self.comments = comments.sorted(by: { first, second in
            first.createDate < second.createDate
        })
    }
    
    //MARK: - Inputs
    
    struct Input {
        let fetchPorfileImage: PublishRelay<(Int, String)>
        let text: ControlProperty<String>
        let sendButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let comments: BehaviorRelay<[Comment]>
        let profileImageData: PublishRelay<(Int, Data)>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let hidePlaceholder: PublishRelay<Bool>
        let sendButtonEnabled: PublishRelay<Bool>
        let clearText: PublishRelay<String>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let comments = BehaviorRelay<[Comment]>(value: self.comments)
        let profileImageData = PublishRelay<(Int, Data)>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let hidePlaceholder = PublishRelay<Bool>()
        let sendButtonEnabled = PublishRelay<Bool>()
        let clearText = PublishRelay<String>()
        
        
        input.fetchPorfileImage
            .bind(with: self) { owner, value in
                NetworkManager.shared.fetchImageData(imagePath: value.1) { result in
                    switch result {
                    case .success(let data):
                        profileImageData.accept((value.0, data))
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.text
            .bind(with: self) { owner, value in
                owner.content = value
                
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    hidePlaceholder.accept(false)
                    sendButtonEnabled.accept(false)
                } else {
                    hidePlaceholder.accept(true)
                    sendButtonEnabled.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.sendButtonTapped
            .map({ [weak self] _ in
                guard let self else { return "" }
                return self.content
            })
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .bind(with: self) { owner, value in
                NetworkManager.shared.performRequest(api: .commentUpload(postID: owner.postID, comment: value), model: Comment.self)
                    .asObservable()
                    .bind { result in
                        switch result {
                        case .success(let data):
                            owner.comments.append(data)
                            comments.accept(owner.comments)
                            clearText.accept("")
                            owner.newCommentUpload()
                            
                        case .failure(let error):
                            networkError.accept((error, RouterType.commnetUpload))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            comments: comments,
            profileImageData: profileImageData,
            networkError: networkError,
            hidePlaceholder: hidePlaceholder,
            sendButtonEnabled: sendButtonEnabled,
            clearText: clearText
        )
    }
}
