//
//  Networking.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 07/12/2020.
//

import Foundation
//
//public struct Parallel<A> {
//  public let run: (@escaping (A) -> Void) -> Void
//
//  public init(_ run: @escaping (@escaping (A) -> Void) -> Void) {
//    self.run = run
//  }
//
//  public func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
//    Parallel<B> { callback in
//      self.run { a in
//        f(a).run { b in
//          callback(b)
//        }
//      }
//    }
//  }
//
//  public func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
//    Parallel<B> { callback in
//      self.run { a in callback(f(a)) }
//    }
//  }
//
//}


public struct Parallel<A: APIRequest> {
  public let run: (@escaping (A) -> Void) -> Void
  
  public init(_ run: @escaping (@escaping (A) -> Void) -> Void) {
    self.run = run
  }
  
  //     let task = urlSession.dataTask(with: self.request) { (data: Data?, response: URLResponse?, error: Error?) in
  
//  public func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
//    Parallel<B> { callback in
//      self.run { a in
//        f(a).run { b in
//          callback(b)
//        }
//      }
//    }
//  }
//
//  public func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
//    Parallel<B> { callback in
//      self.run { a in callback(f(a)) }
//    }
//  }
  
}

extension Networking where T == Travel {
  public static let travel = Self(
    baseUrl: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno",
    endpoint: "/autocompletaStazione",
    httpMethod: "GET",
    data: nil
  )
  
  public static func autocompleteStation(with s: String, urlSession: URLSession? = URLSession.shared) -> Self {
    Self(
      baseUrl: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno",
      endpoint: "/autocompletaStazione/\(s)",
      httpMethod: "GET",
      data: nil
    )
  }
}

public struct Networking<T: Codable> {
  public var request: URLRequest
  public var response: T?
  
  private var data: Data?
  
  private var parsing: ((String) -> T?)? = nil
  
  public init(
    baseUrl: String,
    endpoint: String,
    httpMethod: String? = "GET",
    data: Data? = nil,
    parsing: ((String) -> T?)? = nil
  ) {
    guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
      fatalError("malformed url")
    }
    
    self.request = URLRequest(
      url: url,
      cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData,
      timeoutInterval: 10
    )
    
    self.request.httpMethod = httpMethod
    self.data = data
    self.parsing = parsing
  }
  
  public func decode() throws -> T {
    guard let data = self.data else {
      throw NSError(domain: "data is empty", code: 1, userInfo: nil)
    }
    
    return try JSONDecoder().decode(T.self, from: data)
  }
  
  public func parse(_ f: @escaping (String) -> T?) -> T? {
    guard
      let data = self.data,
      let s = String(data: data, encoding: .utf8) else {
      return nil
    }
    
    return f(s)
  }
  
  public func run(
    urlSession: URLSession = .shared,
    completion: @escaping ResultCompletion<Data>
  ) -> URLSessionDataTask {
    
    let task = urlSession.dataTask(with: self.request) { (data: Data?, response: URLResponse?, error: Error?) in
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
        
        completion(.failure(APIError.code(statusCode, self.request)))
        return
      }
    }
    
    task.resume()
    
    return task
  }
  
  public func performAPI(
    urlSession: URLSession = .shared,
    completion: @escaping ResultCompletion<Data>
  ) -> URLSessionDataTask {
    let task = urlSession.dataTask(with: self.request) { (data: Data?, response: URLResponse?, error: Error?) in
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
        
        completion(.failure(APIError.code(statusCode, self.request)))
        return
      }
    }
    
    task.resume()
    
    return task
  }
  
}
