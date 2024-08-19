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
    
    
    func performRequest<T: Decodable>(api: Router, model: T.Type) -> Single<Result<T, NetworkError>> {
        
        return Single.create { single -> Disposable in
            do {
                let request = try api.asURLRequest()
                
                AF.request(request)
                    .validate(statusCode: 200...299)
                    .responseDecodable(of: T.self) { response in
                        
                        if response.response?.statusCode == 419 { //토큰 만료 -> 액세스 토큰 갱신 시도
                            self.refreshToken { result in
                                switch result {
                                case .success(_):
                                    print("DEBUG: 액세스 토큰 갱신 완료")
                                case .failure(let error):
                                    print("Error: 액세스 토큰 갱신 실패")
                                    single(.success(.failure(error)))
                                    return
                                }
                            }
                        }
                        
                        switch response.result {
                        case .success(let value):
                            single(.success(.success(value)))
                        
                        case .failure(let error):
                            print("Error: \(error)")
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
    
    func fetchImageData(imagePath: String, completionHandler: @escaping (Result<Data, NetworkError>) -> Void) {
        do {
            let request = try Router.image(imagePath: imagePath).asURLRequest()
            AF.request(request)
                .validate(statusCode: 200...299)
                .responseData { response in
                    
                    if response.response?.statusCode == 419 {
                        //토큰 만료 -> 액세스 토큰 갱신 시도
                        self.refreshToken { result in
                            switch result {
                            case .success(_):
                                print("DEBUG: 액세스 토큰 갱신 완료")
                            case .failure(let error):
                                print("Error: 액세스 토큰 갱신 실패")
                                completionHandler(.failure(error))
                                return
                            }
                        }
                    }
                    
                    switch response.result {
                    case .success(let value):
                        completionHandler(.success(value))
                    
                    case .failure(let error):
                        print("Error: \(error)")
                        switch error {
                        case .createURLRequestFailed(let error):
                            print(error)
                            completionHandler(.failure(NetworkError.failedToCreateRequest))
                            
                        case .invalidURL(let url):
                            print("Error URL: \(url)")
                            completionHandler(.failure(NetworkError.invalidURL))
                            
                        case .responseValidationFailed(let reason):
                            switch reason {
                            case .unacceptableStatusCode(let code):
                                completionHandler(.failure(NetworkError.statusError(codeNumber: code)))
                            default:
                                break
                            }
                            
                        case .sessionTaskFailed(let error as URLError):
                            if error.code == .notConnectedToInternet {
                                completionHandler(.failure(NetworkError.notConnectedInternet))
                            }
                        default:
                            break
                        }
                    }
                }
        } catch {
            print("Error: request 생성 실패 \(error)")
            completionHandler(.failure(NetworkError.failedToCreateRequest))
        }
    }
    
    func refreshToken(completionHandler: @escaping (Result<Bool, NetworkError>) -> Void) {
        do {
            let request = try Router.refresh.asURLRequest()
            
            AF.request(request).validate(statusCode: 200...299).responseDecodable(of: RefreshModel.self) { response in
                
                if response.response?.statusCode == 418 { //리프레시 토큰 만료
                    UserDefaultsManager.shared.removeAll()
                    completionHandler(.failure(NetworkError.refreshTokenExpired))
                    return
                }
                
                switch response.result {
                case .success(let value):
                    print("DEBUG: 리프레쉬 토큰 요청 성공")
                    UserDefaultsManager.shared.accessToken = value.accessToken
                    completionHandler(.success(true))
                    return
                    
                case .failure(let error):
                    print("Error: 리프레쉬 토큰 요청 실패", error)
                    
                    switch error {
                    case .responseValidationFailed(let reason):
                        switch reason {
                        case .unacceptableStatusCode(let code):
                            if code == 401 {
                                completionHandler(.failure(NetworkError.invalidToken))
                                return
                            } else {
                                completionHandler(.failure(NetworkError.statusError(codeNumber: code)))
                                return
                            }
                        default:
                            break
                        }
                    default:
                        completionHandler(.failure(NetworkError.notConnectedInternet))
                        return
                    }
                }
            }
        } catch {
            print("Error: request 만들기 실패: \(error)")
            completionHandler(.failure(NetworkError.failedToCreateRequest))
        }
    }
    
    
    
}
