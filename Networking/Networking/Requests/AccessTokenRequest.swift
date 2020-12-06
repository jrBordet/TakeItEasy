////
////  AccessTokenRequest.swift
////  RewardKit
////
////  Created by Jean Raphael Bordet on 19/07/2019.
////
//
//import Foundation
//
//struct AccessTokenRequest: APIRequest, CustomDebugStringConvertible {
//    var debugDescription: String {
//        return request.debugDescription
//    }
//    
//    typealias Response = AccessToken
//    
//    public var endpoint: String = "/oauth2/token"
//    
//    public var request: URLRequest {
//        guard let authUrl = RewardKitManager.env.authBaseUrl() + endpoint |> URL.init(string:) else {
//            fatalError()
//        }
//        
//        var request = URLRequest(url: authUrl)
//        
//        request.setValue(RewardKitManager.env.Authorization(), forHTTPHeaderField: "Authorization")
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        
//        request.httpMethod = "POST"
//        
//        let postString = String(format: "client_id=%@&grant_type=%@&scope=%@", RewardKitManager.env.client_id(), RewardKitManager.env.grant_type(), RewardKitManager.env.scope())
//        
//        request.httpBody = postString.data(using: .utf8)
//        
//        return request
//    }
//}
