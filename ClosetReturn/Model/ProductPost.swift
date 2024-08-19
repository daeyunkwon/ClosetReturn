//
//  ProductPost.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import Foundation

struct ProductPostData: Decodable {
    let data: [ProductPost]
    let next_cursor: String
}

struct ProductPost: Decodable {
    let post_id: String
    let product_id: String
    let title: String
    let content: String
    let content1: String
    let content2: String
    let content3: String
    let content4: String
    let content5: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let comments: [Comment]
}

struct Creator: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
}

struct Comment: Decodable {
    let comment_id: String
    let createdAt: String
    let creator: Creator
}
