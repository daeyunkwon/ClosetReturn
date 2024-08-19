//
//  Login.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import Foundation

struct Login: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String?
    let accessToken: String
    let refreshToken: String
}
