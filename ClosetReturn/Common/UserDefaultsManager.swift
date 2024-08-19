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
        case refresh
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
            return UserDefaults.standard.string(forKey: UserDefaultsKey.refresh.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.refresh.rawValue)
        }
    }
}
