//
//  NetworkError.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/15/24.
//

import Foundation

enum NetworkError: Error, Equatable {
    case notConnectedInternet
    case invalidURL
    case failedToCreateRequest
    case unknownRespose
    case statusError(codeNumber: Int)
    case noData
    case decodingError
    case refreshTokenExpired
    case invalidToken
    case invalidNickname
}

extension NetworkError {
    var errorDescription: String {
        switch self {
        case .notConnectedInternet:
            return "Error: 인터넷 연결 안됨"
        case .invalidURL:
            return "Error: 유효하지 않은 URL"
        case .failedToCreateRequest:
            return "Error: request 생성 실패"
        case .unknownRespose:
            return "Error: 알 수 없는 응답"
        case .statusError(let codeNumber):
            return "Error: 응답 실패 상태코드:\(codeNumber)"
        case .noData:
            return "Error: 데이터 없음"
        case .decodingError:
            return "Error: 데이터 디코딩 실패"
        case .refreshTokenExpired:
            return "Error: 리프레시 토큰 만료됨"
        case .invalidToken:
            return "Error: 유효하지 않은 액세스 및 리프레시 토큰"
        case .invalidNickname:
            return "Error: 유효하지 않은 닉네임"
        }
    }
}
