//
//  UploadFeedRequestModel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/26/24.
//

import Foundation

struct UploadFeedRequestModel: Encodable {
    let content: String
    let product_id: String
    let files: [String]
}
