////
////  CaveauxListRequest.swift
////  RewardKit
////
////  Created by Jean Raphael Bordet on 19/07/2019.
////
//
//import Foundation
//
//struct CaveauxListRequest: APIRequest, CustomDebugStringConvertible {
//    var debugDescription: String {
//        return request.debugDescription
//    }
//    
//    typealias Response = CaveauAll
//
//    public var endpoint: String = "/caveau/all/"
//
//    private (set) var idUser: String
//
//    public var request: URLRequest {
//        guard let url = RewardKitManager.env.baseUrl() + "\(endpoint)\(idUser)" |> URL.init(string:) else {
//            fatalError()
//        }
//
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(retrieveAccessToken())", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "GET"
//
//        return request
//    }
//
//    public init(idUser: String) {
//        self.idUser = idUser
//    }
//}
