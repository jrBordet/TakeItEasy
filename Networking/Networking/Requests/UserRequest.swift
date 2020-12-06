////
////  UserRequest.swift
////  RewardKit
////
////  Created by Jean Raphael Bordet on 19/07/2019.
////
//
//import Foundation
//
//struct UserRequest: APIRequest, CustomDebugStringConvertible {
//    var debugDescription: String {
//        return request.debugDescription
//    }
//    
//    typealias Response = [Points]
//    
//    public var endpoint: String = ""
//    
//    private (set) var idUser: String
//    
//    public var request: URLRequest {
//        guard let url = RewardKitManager.env.baseUrl() + "/user/\(idUser)/balance" |> URL.init(string:) else {
//            fatalError()
//        }
//        
//        var request = URLRequest(url: url)
//        request.setValue("Bearer \(retrieveAccessToken())", forHTTPHeaderField: "Authorization")
//        
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
//        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
//        request.setValue("\(appVersion)(\(buildNumber))", forHTTPHeaderField: "app-version")
//
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let identifier = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8, value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//        request.setValue("\(identifier)", forHTTPHeaderField: "app-device")
//        
//        request.setValue("mod-ios", forHTTPHeaderField: "app-platform")
//
//        let systemVersion = UIDevice.current.systemVersion
//        request.setValue("\(systemVersion)", forHTTPHeaderField: "app-others") //sistema operativo;connection type,
//        
//        request.httpMethod = "GET"
//    
//        return request
//    }
//    
//    public init(idUser: String) {
//        self.idUser = idUser
//    }
//    
//}
