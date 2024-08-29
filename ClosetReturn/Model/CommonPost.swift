//
//  CommonPost.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/28/24.
//

import Foundation

struct CommonPost: Decodable {
    let post_id: String
    let product_id: String
    let title: String?
    let price: Int?
    let content: String
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let createdAt: String
    let files: [String]
    let like: [String]?
    let like2: [String]?
    let hashTags: [String]
    let comments: [Comment]
}
