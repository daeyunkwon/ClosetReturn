//
//  UIView+Extension.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    func bounce() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 0.9, 1.1, 1.0]
        bounceAnimation.duration = 0.4
        layer.add(bounceAnimation, forKey: "bounce")
    }
}
