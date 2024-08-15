//
//  NetworkManager.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import Foundation

import Alamofire

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
    
    func loginUser(email: String, password: String, completionHandler: @escaping (Result<String, NetworkError>) -> Void) {
        do {
            let request = try Router.loginUser(email: email, password: password).asURLRequest()
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                    case .failure(let error):
                        print(error)
                        print("실패됨")
                        completionHandler(.failure(.statusError(codeNumber: error.responseCode ?? 0)))
                    }
            }
        } catch {
            print("Error: request 생성 실패 \(error)")
        }
    }
    
    
    
    
    
}
