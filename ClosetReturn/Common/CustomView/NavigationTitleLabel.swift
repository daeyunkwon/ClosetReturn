//
//  NavigationTitleLabel.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit

final class NavigationTitleLabel: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        
        self.text = text
        font = Constant.Font.brandFont
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }   
}
