//
//  Reusable.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

protocol Reusable: AnyObject {
    static var identifier: String { get }
}

extension UIView: Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}
