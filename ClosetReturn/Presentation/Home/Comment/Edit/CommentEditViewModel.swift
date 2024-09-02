//
//  CommentEditViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import Foundation

import RxSwift
import RxCocoa

final class CommentEditViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var comment: String
    private var postID: String
    private var commnetID: String
    
    var editSucceed: (String) -> Void = { sender in }
    
    //MARK: - Init
    
    init(comment: String, postID: String, commnetID: String) {
        self.comment = comment
        self.postID = postID
        self.commnetID = commnetID
    }
    
    //MARK: - Inputs
    
    struct Input {
        let comment: ControlProperty<String>
        let cancelButtonTapped: ControlEvent<Void>
        let doneButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let comment: BehaviorRelay<String>
        let cancelButtonTapped: ControlEvent<Void>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let commnetModifySucceed: PublishRelay<Void>
    }
    
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let comment = BehaviorRelay<String>(value: self.comment)
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let commnetModifySucceed = PublishRelay<Void>()
        
        input.comment
            .skip(1)
            .bind(with: self) { owner, value in
                owner.comment = value
                comment.accept(owner.comment)
            }
            .disposed(by: disposeBag)
        
        input.doneButtonTapped
            .bind(with: self) { owner, _ in
                NetworkManager.shared.performRequest(api: .commentModify(postID: owner.postID, commentID: owner.commnetID, comment: owner.comment), model: Comment.self)
                    .asObservable()
                    .bind(with: self) { owner, result in
                        switch result {
                        case .success(let data):
                            owner.editSucceed(data.content)
                            commnetModifySucceed.accept(())
                        
                        case .failure(let error):
                            networkError.accept((error, RouterType.commentModify))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            comment: comment,
            cancelButtonTapped: input.cancelButtonTapped,
            networkError: networkError,
            commnetModifySucceed: commnetModifySucceed
        )
    }
}
