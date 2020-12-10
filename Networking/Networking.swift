//
//  Networking.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 07/12/2020.
//

import Foundation
import RxSwift
import RxCocoa

public struct Networking<T: APIRequest> {
	public var API: T
	public var response: T.Response?
			
	public init(
		API: T,
		httpMethod: String? = "GET"
	) {
		self.API = API
	}
	
	public func data(with urlSession: URLSession = .shared, transform: @escaping(String) -> T.Response) -> Observable<T.Response> {
		urlSession
			.rx
			.data(request: self.API.request)
			.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.map {
				guard let result = String(data: $0, encoding: .utf8) else {
					throw NSError(domain: "error on data encoding", code: 1, userInfo: nil)
				}
				
				return result
			}
			.map (transform)
	}
	
	public func json(with urlSession: URLSession = .shared) -> Observable<T.Response> {
		urlSession
			.rx
			.data(request: self.API.request)
			.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.map { data -> T.Response in
				do {
					return try JSONDecoder().decode(T.Response.self, from: data)
				} catch let error {
						throw RxCocoaURLError.deserializationError(error: error)
				}
			}
	}
}
