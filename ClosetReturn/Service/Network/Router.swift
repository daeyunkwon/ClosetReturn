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
    case postUpload(uploadPostRequest: UploadPostRequestModel?, uploadFeedRequest: UploadFeedRequestModel?)
    case postModify(postID: String, uploadPostRequest: UploadPostRequestModel?, uploadFeedRequest: UploadFeedRequestModel?)
    case postDelete(postID: String)
    case commentUpload(postID: String, comment: String)
    case commentModify(postID: String, commentID: String, comment: String)
    case commentDelete(postID: String, commentID: String)
    case like2(postID: String, isLike: Bool)
    case likeFetch(next: String, limit: String)
    case like2Fetch(next: String, limit: String)
    case targetUserProfile(userID: String)
    case paymentsValid(imp_uid: String, post_id: String)
    case paymentMe
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
    case commentModify
    case commnetDelete
    case like2
    case likeFetch
    case like2Fetch
    case targetUserProfile
    case paymentsValid
    case paymentMe
}

extension Router: URLRequestConvertible {
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation, .joinUser, .loginUser, .like, .imageUpload, .postUpload, .commentUpload, .like2, .paymentsValid:
            return .post
            
        case .posts, .imageFetch, .refresh, .postDetail, .likeFetch, .like2Fetch, .targetUserProfile, .paymentMe:
            return .get
            
        case .postModify, .commentModify:
            return .put
            
        case .postDelete, .commentDelete:
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
        case .postModify(let postID, _, _): return APIURL.postModifyURL(postID: postID)
        case .postDelete(let postID): return APIURL.postDeleteURL(postID: postID)
        case .commentUpload(let postID, _): return APIURL.commentUploadURL(postID: postID)
        case .commentModify(let postID, let commentID, _): return APIURL.commentModifyURL(postID: postID, commentID: commentID)
        case .commentDelete(let postID, let commentID): return APIURL.commentDeleteURL(postID: postID, commentID: commentID)
        case .like2(let postID, _): return APIURL.like2URL(postID: postID)
        case .likeFetch(_, _): return APIURL.likeFetchURL
        case .like2Fetch(_, _): return APIURL.like2FetchURL
        case .targetUserProfile(let userID): return APIURL.targetUserProfileFetchURL(userID: userID)
        case .paymentsValid: return APIURL.payments
        case .paymentMe: return APIURL.paymentMe
        }
    }
    
    var header: [String: String] {
        switch self {
        case .emailValidation, .joinUser, .loginUser:
            return [
                HeaderKey.contentType.rawValue: HeaderKey.json.rawValue,
                HeaderKey.sesacKey.rawValue: APIKey.sesacKey
            ]
        
        case .posts, .imageFetch, .postDelete, .commentDelete, .likeFetch, .like2Fetch, .targetUserProfile, .paymentMe:
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
            
        case .like, .postDetail, .postUpload, .postModify, .commentUpload, .commentModify, .like2, .paymentsValid:
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
            
        case .like(_, let isLike), .like2(_, let isLike):
            return try? JSONEncoder().encode([
                BodyKey.like_status.rawValue: isLike
            ])
            
        case .postUpload(let uploadPostRequest, let uploadFeedRequest):
            if uploadPostRequest != nil && uploadFeedRequest == nil {
                return try? JSONEncoder().encode(uploadPostRequest)
            } else {
                return try? JSONEncoder().encode(uploadFeedRequest)
            }
            
        case .postModify(_, let uploadPostRequest, let uploadFeedRequest):
            if uploadPostRequest != nil && uploadFeedRequest == nil {
                return try? JSONEncoder().encode(uploadPostRequest)
            } else {
                return try? JSONEncoder().encode(uploadFeedRequest)
            }
            
        case .commentUpload(_, let comment):
            return try? JSONEncoder().encode([
                BodyKey.content.rawValue: comment
            ])
            
        case .commentModify(_, _, let comment):
            return try? JSONEncoder().encode([
                BodyKey.content.rawValue: comment
            ])
            
        case .paymentsValid(let imp_uid, let post_id):
            return try? JSONEncoder().encode([
                BodyKey.imp_uid.rawValue: imp_uid,
                BodyKey.post_id.rawValue: post_id
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
            
        case .likeFetch(let next, let limit), .like2Fetch(let next, let limit):
            return [
                URLQueryItem(name: "next", value: next),
                URLQueryItem(name: "limit", value: limit),
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
