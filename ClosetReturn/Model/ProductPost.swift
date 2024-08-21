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
    var likes: [String]
    var likes2: [String]
    var comments: [Comment]
    var price: Int?
    
    var createDateString: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
    
        guard let date = dateFormatter.date(from: self.createdAt) else {
            return "NONE"
        }

        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
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
