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
    
    private enum UserDefaultsKey: String {
        case accessToken
        case refreshToken
        case userID
        case likeProducts
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
            return UserDefaults.standard.string(forKey: UserDefaultsKey.refreshToken.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.refreshToken.rawValue)
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
    
    func removeAll() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.accessToken.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.refreshToken.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.userID.rawValue)
    }
}
