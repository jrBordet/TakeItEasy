//
//  URLRequests+.swift
//  RewardKit
//
//  Created by Jean Raphael Bordet on 18/07/2019.
//  Copyright © 2019 Synesthesia. All rights reserved.
//

import Foundation
import UIKit

public enum HTTPStatusCodes: Int {
    case Ok = 200 // 200 Success
    case Created = 201 // incomplete login
	case NoContent = 204
    
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

extension HTTPStatusCodes {
	public static func decode(from response: URLResponse?) -> HTTPStatusCodes? {
		guard let HTTPURLResponse = (response as? HTTPURLResponse),
			let statusCode = HTTPStatusCodes(rawValue: HTTPURLResponse.statusCode) else {
				return nil
		}
		
		return statusCode
	}
}
