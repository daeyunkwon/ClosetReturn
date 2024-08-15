//
//  Constant.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

enum Constant {
    enum Color {
        static let brandColor = UIColor(red: 0.33, green: 0.60, blue: 0.93, alpha: 1.00)
        
        enum View {
            static let viewBackgroundColor: UIColor = .systemBackground
            static let navigationBarTintColor: UIColor = .systemFill
        }
        
        enum Text {
            static let titleColor: UIColor = .label
            static let bodyColor: UIColor = .label
            static let secondaryColor: UIColor = .lightGray
        }
        
        enum Icon {
            static let primaryColor: UIColor = .systemBlue
        }
        
        enum Button {
            static let titleColor: UIColor = .white
        }
    }
    
    enum Font {
        static let brandFont = UIFont(name: "Partial-Sans-KR", size: 30)
        static let titleFont: UIFont = .systemFont(ofSize: 20, weight: .heavy)
        static let bodyFont: UIFont = .systemFont(ofSize: 17)
        static let secondaryFont: UIFont = .systemFont(ofSize: 14)
    }
}
