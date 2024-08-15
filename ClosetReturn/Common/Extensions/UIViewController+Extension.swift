//
//  UIViewController+Extension.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

extension UIViewController {
    func showNetworkRequestFailAlert(errorType: NetworkError) {
        var message: String = "데이터를 불러오는데 실패하였습니다. 네트워크 연결 상태를 확인 후 다시 시도해 주세요."
        
        switch errorType {
            
        case .statusError(let codeNumber):
            switch codeNumber {
            case 400:
                message = "이메일 또는 비밀번호를 입력해주세요."
            case 401:
                message = "미가입 계정 정보 혹은 비밀번호가 일치하지 않습니다. 계정을 확인해주세요."
            case 409:
                message = "사용이 불가한 이메일입니다."
            case 420:
                message = "인증키가 유효하지 않아 서버에 접근이 실패되었습니다. 잠시 후 다시 시도해 주세요."
            case 429:
                message = "과호출로 인해 서버에서 데이터 제공이 거부되었습니다. 잠시 후 다시 시도해 주세요."
            case 444:
                message = "비정상 URL 접근으로 인해 데이터를 불러오는데 실패하였습니다. 잠시 후 다시 시도해 주세요."
            case 500:
                message = "서버에 문제가 발생하여 데이터를 불러오는데 실패하였습니다. 잠시 후 다시 시도해 주세요."
            default:
                break
            }
        default:
            break
        }
        
        let alert = UIAlertController(title: "시스템 알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
