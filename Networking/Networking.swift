//
//  Networking.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 07/12/2020.
//

import Foundation
import RxSwift
import RxCocoa
import os.log

extension OSLog {
	private static var subsystem = Bundle.main.bundleIdentifier!
	
	static let networking = OSLog(subsystem: subsystem, category: "Networking")
}

public struct Networking<T: APIRequest> {
	public var API: T
	public var response: T.Response?
	public let httpMethod: String
	
	public init(
		API: T,
		httpMethod: String = "GET"
	) {
		self.API = API
		self.httpMethod = httpMethod
	}
	
	public func data(with urlSession: URLSession = .shared, transform: @escaping(String) -> T.Response) -> Observable<T.Response> {
		make(with: urlSession, parse: transform)
	}
	
	public func json(with urlSession: URLSession = .shared) -> Observable<T.Response> {
		make(with: urlSession)
	}
	
	public static func mock(_ data: Data) -> T.Response {
		do {
			return try JSONDecoder().decode(T.Response.self, from: data)
		} catch let e {
			fatalError(e.localizedDescription)
		}
	}
	
	private func make(with urlSession: URLSession = .shared, parse: ((String) -> T.Response)? = nil) -> Observable<T.Response> {
		return Observable<T.Response>.create { observer -> Disposable in
			os_log("make %{public}@ ", log: OSLog.networking, type: .info, ["request",self.API.request.url?.absoluteString.removingPercentEncoding])
						
			urlSession.dataTask(with: self.API.request) { (data, response, error) in
				guard let statusCode = HTTPStatusCodes.decode(from: response) else {
					observer.onError(APIError.undefinedStatusCode)
					return
				}
				
				os_log("statusCode %{public}@ ", log: OSLog.networking, type: .info, ["statusCode", statusCode])
				
				guard 200...299 ~= statusCode.rawValue else {
					observer.onError(APIError.code(statusCode))
					return
				}
				
				guard
					let data = data,
					let result = String(data: data, encoding: .utf8) else {
					os_log("statusCode %{public}@ ", log: OSLog.networking, type: .error, ["error", "dataCorrupted"])

					observer.onError(APIError.dataCorrupted)
					return
				}
				
				if let parse = parse {
					observer.onNext(parse(result))
				} else {
					do {
						try observer.onNext(JSONDecoder().decode(T.Response.self, from: data))
						//observer.onCompleted()
					}  catch let error {
						os_log("error %{public}@ ", log: OSLog.networking, type: .error, ["error", error.localizedDescription])

						guard let e = error as? DecodingError else {
							observer.onError(APIError.decoding(error.localizedDescription))
							return
						}
						
						switch e {
						case let .typeMismatch(_, value), let .valueNotFound(_, value):
							if let key = value.codingPath.last {
								observer.onError(APIError.decoding("Decoding error on key '\(key.stringValue)': " + value.debugDescription))
							}
							
							observer.onError(APIError.decoding(value.debugDescription))
						case let .keyNotFound(_, value):
							observer.onError(APIError.decoding(value.underlyingError?.localizedDescription ?? ""))
						case let .dataCorrupted(value):
							observer.onError(APIError.decoding(value.underlyingError?.localizedDescription ?? ""))
						@unknown default:
							observer.onError(APIError.dataCorrupted)
						}
					}
				}
				
				observer.onCompleted()
			}.resume()
			
			return Disposables.create()
		}
	}
}
