//
//  URLRequests+.swift
//  RewardKit
//
//  Created by Jean Raphael Bordet on 18/07/2019.
//  Copyright © 2019 Synesthesia. All rights reserved.
//

import Foundation
import UIKit

enum HTTPStatusCodes: Int {
    // 200 Success
    case Ok = 200
    case Created = 201 // incomplete login
    
    // 300
    case NotModified = 300
    
    // 400 Client Error
    case BadRequest = 400
    case Unauthorized = 401
    case Forbidden = 403
    case NotFound = 404
    case Duplicated = 409
    case ValdiationFail = 422
    
    // 500 Server Error
    case InternalServerError = 500
}

//extension String {
//    func download(_ closure: @escaping (UIImage) -> ()) -> URLSessionDataTask? {
//        guard let url = URL(string: self) else { return nil }
//        return url.download(closure)
//    }
//}
