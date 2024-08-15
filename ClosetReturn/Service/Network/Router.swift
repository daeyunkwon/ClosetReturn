//
//  Router.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import Foundation

import Alamofire

enum Router {
    case emailValidation(email: String)
    case joinUser(email: String, password: String, nick: String, phoneNum: String?, birthDay: String?)
    case loginUser(email: String, password: String)
}

extension Router: URLRequestConvertible {
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation:
            return .get
            
        case .joinUser, .loginUser:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .emailValidation: return APIURL.validationEmailPath
        case .joinUser: return APIURL.usersJoin
        case .loginUser: return APIURL.usersLogin
        }
    }
    
    var header: [String: String] {
        switch self {
        case .emailValidation, .joinUser, .loginUser:
            return [
                HeaderKey.contentType.rawValue: HeaderKey.json.rawValue,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey
            ]
        }
    }
    
    var body: Data? {
        switch self {
        case .emailValidation(let email):
            return try? JSONEncoder().encode([
                BodyKey.email.rawValue: email
            ])
            
        case .joinUser(let email, let password, let nick, let phoneNum, let birthDay):
            return try? JSONEncoder().encode([
                BodyKey.email.rawValue: email,
                BodyKey.password.rawValue: password,
                BodyKey.nick.rawValue: nick,
                BodyKey.phoneNum.rawValue: phoneNum,
                BodyKey.birthDay.rawValue: birthDay
            ])
            
        case .loginUser(let email, let password):
            return try? JSONEncoder().encode([
                BodyKey.email.rawValue: email,
                BodyKey.password.rawValue: password
            ])
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        
        
        default:
            return nil
        }
    }
    
    
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        
        //body 데이터 셋팅
        if method == .post || method == .put || method == .patch {
            request.httpBody = body
        }
        
        //query 데이터 셋팅
        if method == .get {
            urlComponents.queryItems = query
            guard let newURL = urlComponents.url else {
                throw URLError(.badURL)
            }
            request.url = newURL
        }
        
        return request
    }
}
