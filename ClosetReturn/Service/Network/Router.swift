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
    case posts(next: String, limit: String, product_id: String)
    case imageFetch(imagePath: String)
    case refresh
    case like(postID: String, isLike: Bool)
    case postDetail(postID: String)
    case imageUpload(image: [Data], fileName: String, mimeType: String)
    case postUpload(uploadPostRequest: UploadPostRequestModel)
    case postModify(postID: String, uploadPostRequest: UploadPostRequestModel)
    case postDelete(postID: String)
    case commentUpload(postID: String, comment: String)
}

enum RouterType {
    case emailValidation
    case joinUser
    case loginUser
    case posts
    case image
    case refresh
    case like
    case postDetail
    case imageUpload
    case postUpload
    case postModify
    case postDelete
    case commnetUpload
}

extension Router: URLRequestConvertible {
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation, .joinUser, .loginUser, .like, .imageUpload, .postUpload, .commentUpload:
            return .post
            
        case .posts, .imageFetch, .refresh, .postDetail:
            return .get
            
        case .postModify:
            return .put
            
        case .postDelete:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .emailValidation: return APIURL.validationEmailPath
        case .joinUser: return APIURL.usersJoin
        case .loginUser: return APIURL.usersLogin
        case .posts: return APIURL.posts
        case .imageFetch(let imagePath): return "v1/\(imagePath)"
        case .refresh: return APIURL.refresh
        case .like(let postID, _): return APIURL.likeURL(postID: postID)
        case .postDetail(let postID): return APIURL.postDetailURL(postID: postID)
        case .imageUpload: return APIURL.imageUpload
        case .postUpload: return APIURL.posts
        case .postModify(let postID, _): return APIURL.postModifyURL(postID: postID)
        case .postDelete(let postID): return APIURL.postDeleteURL(postID: postID)
        case .commentUpload(let postID, _): return APIURL.commentUploadURL(postID: postID)
        }
    }
    
    var header: [String: String] {
        switch self {
        case .emailValidation, .joinUser, .loginUser:
            return [
                HeaderKey.contentType.rawValue: HeaderKey.json.rawValue,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey
            ]
        
        case .posts, .imageFetch, .postDelete:
            return [
                HeaderKey.authorization.rawValue: UserDefaultsManager.shared.accessToken,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey,
            ]
            
        case .refresh:
            return [
                HeaderKey.authorization.rawValue: UserDefaultsManager.shared.accessToken,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey,
                HeaderKey.refresh.rawValue: UserDefaultsManager.shared.refreshToken
            ]
            
        case .like, .postDetail, .postUpload, .postModify, .commentUpload:
            return [
                HeaderKey.authorization.rawValue: UserDefaultsManager.shared.accessToken,
                HeaderKey.contentType.rawValue: HeaderKey.json.rawValue,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey,
            ]
            
        default:
            return [:]
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
            
        case .like(_, let isLike):
            return try? JSONEncoder().encode([
                BodyKey.like_status.rawValue: isLike
            ])
            
        case .postUpload(let uploadPostRequest):
            return try? JSONEncoder().encode(uploadPostRequest)
            
        case .postModify(_, let uploadPostRequest):
            return try? JSONEncoder().encode(uploadPostRequest)
            
        case .commentUpload(_, let comment):
            return try? JSONEncoder().encode([
                BodyKey.content.rawValue: comment
            ])
            
        default:
            return nil
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .posts(let next, let limit, let product_id):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit),
                URLQueryItem(name: "product_id", value: product_id),
            ]
            
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
