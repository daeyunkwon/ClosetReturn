//
//  Profile.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/28/24.
//

import Foundation

struct Profile: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
    let followers: [FollowUser]
    let following: [FollowUser]
    let posts: [String]
}

struct FollowUser: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String?
}
