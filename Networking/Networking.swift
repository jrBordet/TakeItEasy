//
//  Networking.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 07/12/2020.
//

import Foundation
import RxSwift
import RxCocoa

public struct Station: Codable {
	public let id: String
	public let name: String
	
	public init(_ id: String, name: String) {
		self.id = id
		self.name = name
	}
	
}

extension String {
	public func parseStations() -> [Station] {
		self
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.split(separator: "\n")
			.map { $0.split(separator: "|") }
			.map { v -> Station? in
				guard v.count == 2 else {
					return nil
				}
				
				return Station(String(v[1]), name: String(v[0]))
			}
			.compactMap { $0 }
	}
}


/// Retrieve stations by the given string
/// Example: [Url example](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mil)
/// Return a list of station as
//    MILANO CENTRALE|S01700
//    MILANO AFFORI|S01078
//    MILANO BOVISA FNM|S01642
/// - Parameter name: the name of the station
/// - Returns: a collection of Station

extension Networking where T == StationsRequest {
	public static func autocompleteStation(with s: String) -> Self {
		Self(
			baseUrl: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno",
			endpoint: "/autocompletaStazione/\(s)",
			httpMethod: "GET",
			data: nil
		)
	}
}

public struct Networking<T: APIRequest> {
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
	
	public func data(with urlSession: URLSession = .shared, transform: @escaping(String) -> T.Response) -> Observable<T.Response> {
		urlSession
			.rx
			.data(request: self.request)
			.observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
			.map {
				guard let result = String(data: $0, encoding: .utf8) else {
					throw NSError(domain: "error on data encoding", code: 1, userInfo: nil)
				}
				
				return result
			}
			.map (transform)
	}
	
}
