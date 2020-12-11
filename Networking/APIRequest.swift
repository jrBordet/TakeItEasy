import Foundation

public protocol APIRequest {
	associatedtype Response: Decodable
	
	var endpoint: String { get }
	
	var request: URLRequest { get }
}

public enum APIError: Error, Equatable {
	case code(HTTPStatusCodes)
	case undefinedStatusCode
	case empty
	case decoding(String)
	case dataCorrupted
}
