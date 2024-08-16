//
//  NetworkManager.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import Foundation

import Alamofire
import RxSwift

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    
    func checkEmailDuplicate(email: String) {
        
        do {
            let request = try Router.emailValidation(email: email).asURLRequest()
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        print(error)
                        print("실패됨")
                    }
            }
        } catch {
            print("Error: request 생성 실패 \(error)")
        }
    }
    
    func joinUser(email: String, password: String, nick: String, phoneNum: String?, birthDay: String?) {
        do {
            let request = try Router.joinUser(email: email, password: password, nick: nick, phoneNum: phoneNum, birthDay: birthDay).asURLRequest()
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        print(error)
                        print("실패됨")
                    }
            }
        } catch {
            print("Error: request 생성 실패 \(error)")
        }
    }
    
    func loginUser(email: String, password: String) -> Single<Result<String, NetworkError>> {
        
        return Single.create { single -> Disposable in
            do {
                let request = try Router.loginUser(email: email, password: password).asURLRequest()
                
                AF.request(request)
                    .validate(statusCode: 200...299)
                    .responseString { response in
                        switch response.result {
                        case .success(let value):
                            single(.success(.success(value)))
                        
                        case .failure(let error):
                            switch error {
                            case .createURLRequestFailed(let error):
                                print(error)
                                single(.success(.failure(NetworkError.failedToCreateRequest)))
                                
                            case .invalidURL(let url):
                                print("Error URL: \(url)")
                                single(.success(.failure(NetworkError.invalidURL)))
                                
                            case .responseValidationFailed(let reason):
                                switch reason {
                                case .unacceptableStatusCode(let code):
                                    single(.success(.failure(NetworkError.statusError(codeNumber: code))))
                                default:
                                    break
                                }
                                
                            case .sessionTaskFailed(let error as URLError):
                                if error.code == .notConnectedToInternet {
                                    single(.success(.failure(NetworkError.notConnectedInternet)))
                                }
                            default:
                                break
                            }
                        }
                    }
            } catch {
                print("Error: request 생성 실패 \(error)")
                single(.success(.failure(NetworkError.failedToCreateRequest)))
            }

            return Disposables.create()
        }
    }
    
    
    
    
    
}
