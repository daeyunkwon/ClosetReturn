//
//  FeedEditViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedEditViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    var postID: String = ""
    var content = ""
    var images: [Data] = []
    private var imageValid = false
    private var contentValid = false
    
    enum InvalidType: String, CaseIterable {
        case image = "피드 이미지를 등록해 주세요"
        case content = "내용을 입력해 주세요"
    }
    
    enum ViewType {
        case new
        case modify
    }
    private let viewType: ViewType
    
    var postUploadSucceed: () -> Void = { }
    
    //MARK: - Init
    
    init(viewType: ViewType) {
        self.viewType = viewType
    }
    
    //MARK: - Inputs
    
    struct Input {
        let photoSelectButtonTapped: ControlEvent<Void>
        let viewDidLoad: PublishRelay<Void>
        let selectedImages: PublishRelay<[Data]>
        let cellXmarkButtonTapped: PublishRelay<Int>
        let cancelButtonTapped: ControlEvent<Void>
        let content: ControlProperty<String>
        let doneButtonTapped: ControlEvent<Void>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let photoSelectButtonTapped: ControlEvent<Void>
        let navigationTitle: PublishRelay<String>
        let selectedImageList: PublishRelay<[Data]>
        let cancelButtonTapped: ControlEvent<Void>
        let hidePlaceholder: PublishRelay<Bool>
        let invalidInfo: PublishRelay<InvalidType>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let succeedUpload: PublishRelay<Void>
        let doneButtonTapped: ControlEvent<Void>
        let content: PublishRelay<String>
    }
    
    //MARK: - Methods
    
    func transform(input: Input) -> Output {
        
        let navigationTitle = PublishRelay<String>()
        let selectedImageList = PublishRelay<[Data]>()
        let hidePlaceholder = PublishRelay<Bool>()
        let invalidInfo = PublishRelay<InvalidType>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let succeedUpload = PublishRelay<Void>()
        let content = PublishRelay<String>()
        
        input.viewDidLoad
            .bind(with: self) { owner, _ in
                switch owner.viewType {
                case .new:
                    navigationTitle.accept("피드 등록")
                case .modify:
                    navigationTitle.accept("피드 수정")
                    if !owner.images.isEmpty {
                        owner.imageValid = true
                        selectedImageList.accept(owner.images)
                    }
                    
                    if !owner.content.isEmpty {
                        owner.contentValid = true
                        content.accept(owner.content)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.selectedImages
            .bind(with: self) { owner, list in
                owner.images = list
                selectedImageList.accept(owner.images)
                owner.imageValid = true
            }
            .disposed(by: disposeBag)
        
        input.cellXmarkButtonTapped
            .bind(with: self) { owner, row in
                owner.images.remove(at: row)
                selectedImageList.accept(owner.images)
            }
            .disposed(by: disposeBag)
        
        input.content
            .skip(1)
            .bind(with: self) { owner, value in
                owner.content = value
                
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.contentValid = false
                    hidePlaceholder.accept(false)
                } else {
                    owner.contentValid = true
                    hidePlaceholder.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.doneButtonTapped
            .bind(with: self) { owner, _ in
                
                //피드 등록 거부
                let validList = [owner.imageValid, owner.contentValid]
                for i in 0...validList.count - 1 {
                    if validList[i] == false {
                        invalidInfo.accept(InvalidType.allCases[i])
                        return
                    }
                }
                
                //상품 등록 허용
                NetworkManager.shared.uploadImage(images: owner.images)
                    .asObservable()
                    .bind(with: self) {
                        owner,
                        result in
                        switch result {
                        case .success(let value):
                            //이미지 업로드 이후에 포스트 업로드 시도
                            let uploadFeedRequest = UploadFeedRequestModel(content: owner.content, product_id: APIKey.feedID, files: value.files)
                            
                            switch owner.viewType {
                            case .new:
                                NetworkManager.shared.performRequest(api: .postUpload(uploadPostRequest: nil, uploadFeedRequest: uploadFeedRequest), model: FeedPost.self)
                                    .asObservable()
                                    .bind(with: self) { owner, result in
                                        switch result {
                                        case .success(_):
                                            print("DEBUG: 포스트 업로드 성공")
                                            succeedUpload.accept(())
                                            
                                        case .failure(let error):
                                            print("DEBUG: 포스트 업로드 실패")
                                            networkError.accept((error, RouterType.postUpload))
                                        }
                                    }
                                    .disposed(by: owner.disposeBag)
                            
                            case .modify:
                                NetworkManager.shared.performRequest(api: .postModify(postID: owner.postID, uploadPostRequest: nil, uploadFeedRequest: uploadFeedRequest), model: FeedPost.self)
                                    .asObservable()
                                    .bind(with: self) { owner, result in
                                        switch result {
                                        case .success(_):
                                            print("DEBUG: 포스트 수정 성공")
                                            succeedUpload.accept(())
                                            
                                        case .failure(let error):
                                            print("DEBUG: 포스트 수정 실패")
                                            networkError.accept((error, RouterType.postUpload))
                                        }
                                    }
                                    .disposed(by: owner.disposeBag)
                            }
                            
                        case .failure(let error):
                            print("DEBUG: 이미지 업로드 실패")
                            networkError.accept((error, RouterType.imageUpload))
                        }
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(
            photoSelectButtonTapped: input.photoSelectButtonTapped,
            navigationTitle: navigationTitle,
            selectedImageList: selectedImageList,
            cancelButtonTapped: input.cancelButtonTapped,
            hidePlaceholder: hidePlaceholder,
            invalidInfo: invalidInfo,
            networkError: networkError,
            succeedUpload: succeedUpload,
            doneButtonTapped: input.doneButtonTapped,
            content: content
        )
    }
}
