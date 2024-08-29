//
//  Payments.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/29/24.
//

import Foundation

struct Payments: Decodable {
    let buyer_id: String?
    let post_id: String?
    let merchant_uid: String?
    let productName: String?
    let price: Int?
    let paidAt: String?
    
    var createDateString: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
    
        guard let date = dateFormatter.date(from: self.paidAt ?? "") else {
            return "NONE"
        }

        dateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}
