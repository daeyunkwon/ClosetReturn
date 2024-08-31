//
//  Follow.swift
//  ClosetReturn
//
//  Created by 권대윤 on 9/1/24.
//

import Foundation

struct Follow: Decodable {
    let nick: String
    let opponent_nick: String
    let following_status: Bool
}
