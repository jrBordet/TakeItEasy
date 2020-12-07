import Foundation

public class NetworkingManager {
  internal static var bundle: Bundle { return Bundle(for: NetworkingManager.self) }
  internal static let cache: URLCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
  internal static var session: URLSession = {
    var config = URLSessionConfiguration.default
    config.urlCache = cache
    return URLSession(configuration: config)
  }()
  
  internal static var maxRetry = 3
  
  public let baseUrl: String = ""
}

public protocol APIRequest {
  associatedtype Response: Decodable
  
  var endpoint: String { get }
  
  var request: URLRequest { get }
  
  var data: Data? { get }
}

public func decode<T: APIRequest>(request r: T, data: Data) -> Result<T.Response> {
  do {
    let result = try JSONDecoder().decode(T.Response.self, from: data)
    return .success(result)
  } catch let error {
    #if DEBUG
    dump(String(data: data, encoding: .utf8))
    #endif
    
    logError(with: error, message: r.request.debugDescription)
    
    return .failure(error)
  }
}

public func performAPI<T: APIRequest>(
  request r: T,
  retry: Int? = 0,
  completion: @escaping ResultCompletion<T.Response>
) -> URLSessionDataTask {
  let task = NetworkingManager.session.dataTask(with: r.request) { (data: Data?, response: URLResponse?, error: Error?) in
    guard let data = data else {
      logError(with: NSError(domain: "empty data", code: 0, userInfo: nil))
      
      completion(.failure(APIError.empty))
      return
    }
    
    #if DEBUG
    logMessage(with: String(data: data, encoding: .utf8) ?? "", tag: "performAPI")
    #endif
    
    guard let statusCode = HTTPStatusCodes.decode(from: response) else {
      completion(.failure(APIError.undefinedStatusCode))
      return
    }
    
    switch statusCode {
    case .Ok:
      completion(decode(request: r, data: data))
      
      return
    default:
      logError(with: NSError(domain: "failure with code \(statusCode)", code: Int(statusCode.rawValue), userInfo: nil))
      
      completion(.failure(APIError.code(statusCode, r.request)))
      return
    }
  }
  
  task.resume()
  
  return task
}

public func performAPI<T: APIRequest>(
  request r: T,
  retry: Int? = 0,
  completion: @escaping ResultCompletion<Data>
) -> URLSessionDataTask {
  let task = NetworkingManager.session.dataTask(with: r.request) { (data: Data?, response: URLResponse?, error: Error?) in
    guard let data = data else {
      logError(with: NSError(domain: "empty data", code: 0, userInfo: nil))
      
      completion(.failure(APIError.empty))
      return
    }
    
    #if DEBUG
    logMessage(with: String(data: data, encoding: .utf8) ?? "", tag: "performAPI")
    #endif
    
    guard let statusCode = HTTPStatusCodes.decode(from: response) else {
      completion(.failure(APIError.undefinedStatusCode))
      return
    }
    
    switch statusCode {
    case .Ok:
      completion(.success(data))
      
      return
    default:
      logError(with: NSError(domain: "failure with code \(statusCode)", code: Int(statusCode.rawValue), userInfo: nil))
      
      completion(.failure(APIError.code(statusCode, r.request)))
      return
    }
  }
  
  task.resume()
  
  return task
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
