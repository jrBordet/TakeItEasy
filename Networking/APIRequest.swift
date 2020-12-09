import Foundation

public struct API {
  var endpoint: String
  var request: URLRequest
  var data: Data?
  
  public init(
    endpoint: String,
    request: URLRequest,
    data: Data?
  ) {
    self.endpoint = endpoint
    self.request = request
    self.data = data
  }
  
  func makeRequest() throws -> URLRequest {
    let components = URLComponents(string: "")
    
    guard let url = components?.url else {
      throw NSError(domain: "", code: -1, userInfo: nil)
    }
    
    return URLRequest(url: url)
  }
}

public protocol APIRequest {
  associatedtype Response: Decodable
  
  var endpoint: String { get }
  
  var request: URLRequest { get }
  
  var data: Data? { get }
}

enum APIError: Error {
  case code(HTTPStatusCodes, URLRequest)
  case undefinedStatusCode
  case empty
  case failedAccessToken(Error)
}

func logError(with e: Error) {
  #if DEBUG
  print("❌ Error")
  dump(e)
  #endif
}

func logError(with e: Error, message: String) {
  #if DEBUG
  print(message)
  logError(with: e)
  #endif
}

func logMessage(with message: String, tag: String){
  #if DEBUG
  print("[\(tag)] \(message)")
  #endif
}
