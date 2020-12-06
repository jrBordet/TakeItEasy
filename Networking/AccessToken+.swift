//
//  AccessToken.swift
//  RewardKit
//
//  Created by Jean Raphael Bordet on 18/07/2019.
//  Copyright © 2019 Synesthesia. All rights reserved.
//

import Foundation

func retrieveAccessToken() -> String {
    guard let token =  UserDefaults.standard.value(forKey: "ACCESS_TOKEN") as? String else {
        return ""
    }
    
    return token
}

func saveAccessToken(token: String) {
    UserDefaults.standard.setValue(token, forKey: "ACCESS_TOKEN")
}
