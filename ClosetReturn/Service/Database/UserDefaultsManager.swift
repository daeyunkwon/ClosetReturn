//
//  UserDefaultsManager.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    private init() {}
    
    private enum UserDefaultsKey: String, CaseIterable {
        case accessToken
        case refreshToken
        case userID
        case likeProducts
        case likeFeed
    }
    
    var accessToken: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.accessToken.rawValue)
        }
    }
    
    var refreshToken: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.refreshToken.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.refreshToken.rawValue)
        }
    }
    
    var userID: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.userID.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.userID.rawValue)
        }
    }
    
    var likeProducts: [String: Bool] {
        get {
            return UserDefaults.standard.dictionary(forKey: UserDefaultsKey.likeProducts.rawValue) as? [String: Bool] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.likeProducts.rawValue)
        }
    }
    
    var likeFeed: [String: Bool] {
        get {
            return UserDefaults.standard.dictionary(forKey: UserDefaultsKey.likeFeed.rawValue) as? [String: Bool] ?? [:]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.likeFeed.rawValue)
        }
    }
    
    func removeAll() {
        UserDefaultsKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}
