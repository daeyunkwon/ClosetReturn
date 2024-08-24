//
//  ProductPostEditViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import Foundation

import RxSwift
import RxCocoa

final class ProductPostEditViewModel: BaseViewModel {
    
    //MARK: - Properties
    
    var postUploadSucceed: (Bool) -> Void = { sender in }
    
    private let disposeBag = DisposeBag()
    
    private var images: [Data] = []
    private var title: String = ""
    private var price: Int = 0
    private var brand: String = ""
    private var size: String = ""
    private var category: String = ""
    private var condition: String = ""
    private var content: String = ""
    
    private var imageValid = false
    private var titleValid = false
    private var priceValid = false
    private var brandValid = false
    private var sizeValid = false
    private var categoryValid = false
    private var conditionValid = false
    private var contentValid = false
    
    enum InvalidType: String, CaseIterable {
        case image = "상품 이미지를 등록해 주세요"
        case title = "제목을 입력해 주세요"
        case price = "가격을 입력해 주세요"
        case brand = "브랜드명을 입력해 주세요"
        case size = "사이즈 정보를 입력해 주세요"
        case category = "카테고리 정보를 입력해 주세요"
        case condition = "컨디션 상태를 선택해 주세요"
        case content = "내용을 입력해 주세요"
    }
    
    //MARK: - Inputs
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let selectedImages: PublishRelay<[Data]>
        let photoSelectButton: ControlEvent<Void>
        let cellXmarkButtonTapped: PublishRelay<Int>
        let doneButtonTapped: ControlEvent<Void>
        let title: ControlProperty<String>
        let price: ControlProperty<String>
        let brand: ControlProperty<String>
        let size: ControlProperty<String>
        let category: ControlProperty<String>
        let conditionSButtonTapped: ControlEvent<Void>
        let conditionAButtonTapped: ControlEvent<Void>
        let conditionBButtonTapped: ControlEvent<Void>
        let conditionCButtonTapped: ControlEvent<Void>
        let content: ControlProperty<String>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let cancelButtonTapped: ControlEvent<Void>
        let photoSelectButtonTapped: ControlEvent<Void>
        let selectedImageList: BehaviorRelay<[Data]>
        let invalidInfo: PublishRelay<InvalidType>
        let priceString: PublishRelay<String>
        let doneButtonTapped: ControlEvent<Void>
        let selectedConditionButton: PublishRelay<String>
        let contentPlaceholder: PublishRelay<Bool>
        let networkError: PublishRelay<(NetworkError, RouterType)>
        let succeedUpload: PublishRelay<Bool>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let selectedImageList = BehaviorRelay<[Data]>(value: self.images)
        let invalidInfo = PublishRelay<InvalidType>()
        let priceString = PublishRelay<String>()
        let selectedConditionButton = PublishRelay<String>()
        let contentPlaceholder = PublishRelay<Bool>()
        let networkError = PublishRelay<(NetworkError, RouterType)>()
        let succeedUpload = PublishRelay<Bool>()
        
        input.doneButtonTapped
            .bind(with: self) {
                owner,
                _ in
                //상품 등록 거부
                let validList = [owner.imageValid, owner.titleValid, owner.priceValid, owner.brandValid, owner.sizeValid, owner.categoryValid, owner.conditionValid, owner.contentValid]
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
                            let uploadPostRequest = UploadPostRequestModel(
                                title: owner.title,
                                price: owner.price,
                                content: owner.content,
                                content1: owner.size,
                                content2: owner.category,
                                content3: owner.brand,
                                content4: owner.condition,
                                content5: nil,
                                product_id: APIKey.productID,
                                files: value.files
                            )
                            NetworkManager.shared.performRequest(api: .postUpload(uploadPostRequest: uploadPostRequest), model: ProductPost.self)
                                .asObservable()
                                .bind(with: self) { owner, result in
                                    switch result {
                                    case .success(_):
                                        print("DEBUG: 포스트 업로드 성공")
                                        succeedUpload.accept(true)
                                        
                                    case .failure(let error):
                                        networkError.accept((error, RouterType.postUpload))
                                    }
                                }
                                .disposed(by: owner.disposeBag)
                            
                        case .failure(let error):
                            networkError.accept((error, RouterType.imageUpload))
                        }
                    }
                    .disposed(by: owner.disposeBag)
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
            .bind(with: self) { owner, index in
                owner.images.remove(at: index)
                selectedImageList.accept(owner.images)
                
                if owner.images.isEmpty {
                    owner.imageValid = false
                } else {
                    owner.imageValid = true
                }
            }
            .disposed(by: disposeBag)
        
        input.title
            .bind(with: self) { owner, value in
                owner.title = value
                
                if owner.title.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.titleValid = false
                } else {
                    owner.titleValid = true
                }
            }
            .disposed(by: disposeBag)
        
        input.price
            .map { $0.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "₩", with: "") }
            .bind(with: self) { owner, value in
                
                if let number = Int(value) {
                    owner.price = number
                    priceString.accept("₩" + number.formatted())
                } else {
                    owner.price = 0
                    priceString.accept("")
                }
                
                if owner.price == 0 {
                    owner.priceValid = false
                } else {
                    owner.priceValid = true
                }
            }
            .disposed(by: disposeBag)
        
        input.brand
            .bind(with: self) { owner, value in
                owner.brand = value
                
                if owner.brand.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.brandValid = false
                } else {
                    owner.brandValid = true
                }
            }
            .disposed(by: disposeBag)
        
        input.size
            .bind(with: self) { owner, value in
                owner.size = value
                
                if owner.size.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.sizeValid = false
                } else {
                    owner.sizeValid = true
                }
            }
            .disposed(by: disposeBag)
        
        input.category
            .bind(with: self) { owner, value in
                owner.category = value
                
                if owner.category.trimmingCharacters(in: .whitespaces).isEmpty {
                    owner.categoryValid = false
                } else {
                    owner.categoryValid = true
                }
            }
            .disposed(by: disposeBag)
        
        let conditionS = input.conditionSButtonTapped
            .map { "S" }
        let conditionA = input.conditionAButtonTapped
            .map { "A" }
        let conditionB = input.conditionBButtonTapped
            .map { "B" }
        let conditionC = input.conditionCButtonTapped
            .map { "C" }
        
        Observable.merge(conditionS, conditionA, conditionB, conditionC)
            .subscribe(with: self) { owner, value in
                owner.condition = value
                
                if owner.condition.isEmpty {
                    owner.conditionValid = false
                } else {
                    owner.conditionValid = true
                }
                
                selectedConditionButton.accept(owner.condition)
            }
            .disposed(by: disposeBag)
        
        input.content
            .bind(with: self) { owner, value in
                owner.content = value
                
                if owner.content.trimmingCharacters(in: .whitespaces).isEmpty {
                    contentPlaceholder.accept(false)
                    owner.contentValid = false
                } else {
                    contentPlaceholder.accept(true)
                    owner.contentValid = true
                }
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            cancelButtonTapped: input.cancelButtonTapped,
            photoSelectButtonTapped: input.photoSelectButton,
            selectedImageList: selectedImageList,
            invalidInfo: invalidInfo,
            priceString: priceString,
            doneButtonTapped: input.doneButtonTapped,
            selectedConditionButton: selectedConditionButton,
            contentPlaceholder: contentPlaceholder,
            networkError: networkError,
            succeedUpload: succeedUpload
        )
    }
}
