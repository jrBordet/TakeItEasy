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

extension APIRequest {
	public func execute(with urlSession: URLSession = .shared, parse: ((String) -> Self.Response)? = nil) -> Observable<Self.Response> {
		return Observable<Self.Response>.create { observer -> Disposable in
			
			os_log("execute %{public}@ ", log: OSLog.networking, type: .info, ["request", request.debugDescription])

			guard let request = self.request else {
				observer.onError(APIError.wrongRequest)
				return Disposables.create()
			}
			
			urlSession.dataTask(with: request) { (data, response, error) in
				guard let statusCode = HTTPStatusCodes.decode(from: response) else {
					observer.onError(APIError.undefinedStatusCode)
					return
				}
				
				os_log("response %{public}@ ", log: OSLog.networking, type: .info, ["statusCode", statusCode])
				
				guard 200...299 ~= statusCode.rawValue else {
					observer.onError(APIError.code(statusCode))
					return
				}
				
				guard
					let data = data,
					let result = String(data: data, encoding: .utf8) else {
					os_log("response %{public}@ ", log: OSLog.networking, type: .error, ["error", "dataCorrupted"])
					
					observer.onError(APIError.dataCorrupted)
					return
				}
				
				if let parse = parse {
					observer.onNext(parse(result))
				} else {
					do {
						let result = try JSONDecoder().decode(Self.Response.self, from: data)
						
						os_log("response %{public}@ ", log: OSLog.networking, type: .debug, ["result", result])
						
						observer.onNext(result)

					}  catch let error {
						os_log("response %{public}@ ", log: OSLog.networking, type: .error, ["error", error.localizedDescription])
						
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
	
	public func data(with urlSession: URLSession = .shared, transform: @escaping(String) -> Self.Response) -> Observable<Self.Response> {
		execute(with: urlSession, parse: transform)
	}
	
	public func json(with urlSession: URLSession = .shared) -> Observable<Self.Response> {
		execute(with: urlSession)
	}
	
	public static func mock(_ data: Data) -> Self.Response {
		do {
			return try JSONDecoder().decode(Self.Response.self, from: data)
		} catch let e {
			fatalError(e.localizedDescription)
		}
	}
}
