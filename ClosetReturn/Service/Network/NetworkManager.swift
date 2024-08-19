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
    
    
    
    
    
    
    
}
