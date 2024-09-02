//
//  FeedPost.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import Foundation

struct FeedPostData: Decodable {
    let data: [FeedPost]
    let next_cursor: String
}

struct FeedPost: Decodable {
    let post_id: String
    let product_id: String
    let content: String
    let createdAt: String
    let creator: Creator
    let files: [String]
    var likes: [String]
    var likes2: [String]
    var comments: [Comment]
    
    var createDateString: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
    
        guard let date = dateFormatter.date(from: self.createdAt) else {
            return "NONE"
        }

        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
}
