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
    
    //MARK: - Inputs
    
    struct Input {
        let cancelButtonTapped: ControlEvent<Void>
        let selectedImages: PublishRelay<[Data]>
        let photoSelectButton: ControlEvent<Void>
        let cellXmarkButtonTapped: PublishRelay<Int>
    }
    
    //MARK: - Outputs
    
    struct Output {
        let cancelButtonTapped: ControlEvent<Void>
        let photoSelectButton: ControlEvent<Void>
        let selectedImageList: BehaviorRelay<[Data]>
    }
    
    //MARK: - Methods

    func transform(input: Input) -> Output {
        
        let selectedImageList = BehaviorRelay<[Data]>(value: self.images)
        
        
        
        
        input.selectedImages
            .bind(with: self) { owner, list in
                owner.images = list
                selectedImageList.accept(owner.images)
            }
            .disposed(by: disposeBag)
        
        input.cellXmarkButtonTapped
            .bind(with: self) { owner, index in
                owner.images.remove(at: index)
                selectedImageList.accept(owner.images)
            }
            .disposed(by: disposeBag)
        
        
        
        
        return Output(
            cancelButtonTapped: input.cancelButtonTapped,
            photoSelectButton: input.photoSelectButton,
            selectedImageList: selectedImageList
        )
    }
}
