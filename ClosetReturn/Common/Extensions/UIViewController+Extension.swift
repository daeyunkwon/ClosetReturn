//
//  UIViewController+Extension.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import UIKit

import Toast

extension UIViewController {
    
    func setRootViewController(_ viewController: UIViewController) {
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = scene.window {
            
            window.rootViewController = viewController
            
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
    
    func showNetworkRequestFailAlert(errorType: NetworkError, routerType: RouterType) {
        var message: String = "오류가 발생하였습니다. 잠시 후 다시 시도해 주세요."
        var errorType = errorType
        print("DEBUG: 얼럿에서 받은 에러타입: \(errorType)")
        
        switch errorType {
            
        case .refreshTokenExpired, .invalidToken:
            message = "로그인 기간이 만료되었어요. 재로그인 해주세요."
            
        case .statusError(let codeNumber):
            switch codeNumber {
            case 400:
                switch routerType {
                case .loginUser: message = "이메일 또는 비밀번호를 입력해주세요."
                case .imageUpload: message = "제한 사항과 맞지 않아 업로드 실패되었습니다.(파일 용량은 5MB 이하만 허용됩니다.)"
                case .commentModify: message = "수정할 내용을 입력해 주세요."
                default: break
                }
                
            case 401:
                switch routerType {
                case .loginUser:
                    message = "미가입 계정 정보 혹은 비밀번호가 일치하지 않습니다. 계정을 확인해주세요."
                default:
                    message = "액세스 토큰이 유효하지 않습니다. 다시 로그인 해주세요."
                    errorType = .invalidToken
                }
                
            case 409:
                switch routerType {
                case .emailValidation:
                    message = "사용이 불가한 이메일입니다."
                case .joinUser:
                    message = "입력하신 닉네임이 이미 사용중인 닉네임으로 사용할 수 없습니다."
                default: break
                }                
                
            case 410:
                switch routerType {
                case .commnetUpload: message = "해당 게시물이 삭제되어 댓글 작성이 실패되었습니다."
                case .commentModify: message = "해당 댓글이 삭제되어 댓글 수정이 실패되었습니다."
                default: break
                }
                
            case 420:
                message = "인증키가 유효하지 않아 서버에 접근이 실패되었습니다. 잠시 후 다시 시도해 주세요."
            case 429:
                message = "과호출로 인해 서버에서 데이터 제공이 거부되었습니다. 잠시 후 다시 시도해 주세요."
            case 444:
                message = "비정상 URL 접근으로 인해 데이터를 불러오는데 실패하였습니다. 잠시 후 다시 시도해 주세요."
            
            case 445:
                message = "수정 및 삭제 권한이 없습니다."
                
            case 500:
                message = "서버에 문제가 발생하여 데이터를 불러오는데 실패하였습니다. 잠시 후 다시 시도해 주세요."
            default: break
            }
            
        case .notConnectedInternet:
            message = "네트워크 연결 상태를 확인 후 다시 시도해 주세요."
        default: break
        }
        
        let alert = UIAlertController(title: "시스템 알림", message: message, preferredStyle: .alert)
        
        if errorType == .refreshTokenExpired || errorType == .invalidToken {
            //재로그인 필요 O
            alert.addAction(UIAlertAction(title: "로그인", style: .default, handler: { [weak self] okAction in
                self?.setRootViewController(UINavigationController(rootViewController: LoginViewController()))
            }))
        } else {
            //재로그인 필요 X
            alert.addAction(UIAlertAction(title: "확인", style: .default))
        }
        
        present(alert, animated: true)
    }
    
    func showEditCancelCheckAlert() {
        let alert = UIAlertController(title: "상품 등록", message: "상품 등록을 그만하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "그만하기", style: .default, handler: {[weak self] okAction in
            self?.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    func showToast(message: String, position: ToastPosition) {
        var style = ToastStyle()
        style.backgroundColor = Constant.Color.brandColor
        view.makeToast(message, position: position, style: style)
    }
}
