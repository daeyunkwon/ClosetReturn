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
    
    private let disposeBag = DisposeBag()
    
    private var images: [Data] = []
    private var title: String = ""
    
    private var imageValid = false
    private var titleValid = false
    
    enum InvalidType: String, CaseIterable {
        case image = "상품 이미지를 등록해 주세요"
        case title = "제목을 입력해 주세요"
    }
    
    //MARK: - Inputs
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let selectedImages: PublishRelay<[Data]>
        let photoSelectButton: ControlEvent<Void>
        let cellXmarkButtonTapped: PublishRelay<Int>
        let doneButtonTapped: ControlEvent<Void>
        let title: ControlProperty<String>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let cancelButtonTapped: ControlEvent<Void>
        let photoSelectButtonTapped: ControlEvent<Void>
        let selectedImageList: BehaviorRelay<[Data]>
        let invalidInfo: PublishRelay<InvalidType>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let selectedImageList = BehaviorRelay<[Data]>(value: self.images)
        let invalidInfo = PublishRelay<InvalidType>()
        
        input.doneButtonTapped
            .bind(with: self) { owner, _ in
                let validList = [owner.imageValid, owner.titleValid]
                for i in 0...validList.count - 1 {
                    if validList[i] == false {
                        invalidInfo.accept(InvalidType.allCases[i])
                        return
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
        
        
        
        
        return Output(
            cancelButtonTapped: input.cancelButtonTapped,
            photoSelectButtonTapped: input.photoSelectButton,
            selectedImageList: selectedImageList,
            invalidInfo: invalidInfo
        )
    }
}
