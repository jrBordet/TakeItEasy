import Foundation

public class RewardKitManager {
    internal static var bundle: Bundle { return Bundle(for: RewardKitManager.self) }
    internal static let cache: URLCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
    internal static var session: URLSession = {
        var config = URLSessionConfiguration.default
        config.urlCache = cache
        return URLSession(configuration: config)
    }()
    
    internal static var maxRetry = 3
}

internal protocol APIRequest {
    associatedtype Response: Decodable
    
    var endpoint: String { get }
    
    var request: URLRequest { get }
}

internal func decode<T: APIRequest>(request r: T, data: Data) -> Result<T.Response> {
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

internal func performAPI<T: APIRequest>(request r: T, retry: Int? = 0, completion: @escaping ResultCompletion<T.Response>) -> URLSessionDataTask {
    let task = RewardKitManager.session.dataTask(with: r.request) { (data: Data?, response: URLResponse?, error: Error?) in
        guard let data = data else {
            completion(.failure(APIError.empty))
            return
        }
        
        #if DEBUG
        dump(r.request)
        #endif
        
        guard let statusCode = HTTPStatusCodes.decode(from: response) else {
            completion(.failure(APIError.undefinedStatusCode))
            return
        }
        
        switch statusCode {
        case .Ok:
            break
        case .Unauthorized:
            logMessage(with: "Unauthorized - 401", tag: "performAPI")
            
            guard let retry = retry, retry <= RewardKitManager.maxRetry else {
                completion( .failure(APIError.code(statusCode, r.request)))
                return
            }
            
            _ = performAPI(request: AccessTokenRequest(), retry: retry + 1) { result in
                switch result {
                case let .failure(e):
                    .failure(APIError.failedAccessToken(e)) |> completion
                case let .success(content):
                    content.access_token |> saveAccessToken
                    // Retry the last request
                    _ = performAPI(request: r,
                                   retry: retry + 1,
                                   completion: completion)
                }
            }
            return
        default:
            completion(.failure(APIError.code(statusCode, r.request)))
            return
        }
        
        logMessage(with: String(data: data, encoding: .utf8) ?? "", tag: "performAPI")
        
        completion(decode(request: r, data: data))
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
