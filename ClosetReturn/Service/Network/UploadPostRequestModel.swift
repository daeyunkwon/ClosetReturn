//
//  UploadPostRequestModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/24/24.
//

import Foundation

struct UploadPostRequestModel: Encodable {
    let title: String
    let price: Int
    let content: String
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let content5: String?
    let product_id: String
    let files: [String]
}
