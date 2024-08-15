//
//  BaseViewModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import Foundation

protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
