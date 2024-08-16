//
//  ViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/14/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Closet Return"
        label.font = UIFont(name: "Partial-Sans-KR", size: 40)
        label.textColor = Constant.Color.brandColor
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
//        NetworkManager.shared.loginUser(email: "c", password: "") { result in
//            switch result {
//            case .success(let success):
//                print(success)
//            case .failure(let failure):
//                self.showNetworkRequestFailAlert(errorType: failure)
//            }
//        }
        
    }


}

