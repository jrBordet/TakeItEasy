//
//  ArrivalsRequest.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//
import Foundation
import RxSwift

public struct Arrival: Codable {
	public let numeroTreno: Int
}

/// Perform an Http request to retrieve all the arrivals from the give station id.
/// Example:
/// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/arrivi/S01700/Mon%20Nov%2020%202017%2008:30:00%20GMT+0100%20)
/// Mon Nov 20 2017 17:30:00 GMT+0100
///
/// - Parameters:
///   - code: the station code. Example S01700
/// - Returns: a collection of Arrivals

public struct ArrivalsRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = [Arrival]
	
	public var endpoint: String = "/arrivi"
	
	private (set) var code: String
	private (set) var date: Date
	
	public var request: URLRequest {
		guard let url = URL(string: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno" + "\(endpoint)/\(code)/\(encoded(date))") else {
			fatalError()
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(code: String, date: Date) {
		self.code = code
		self.date = date
	}
}

extension ArrivalsRequest {
	public static func fetch(from station: String, date: Date = Date(), urlSession: URLSession = .shared) -> Observable<Self.Response> {
		Networking<Self>
			.departure(from: station, date: date)
			.json(with: urlSession)
	}
}


extension Networking where T == ArrivalsRequest {
	public static func departure(from station: String, date: Date = Date()) -> Self {
		Self(
			API: T(code: station, date: date),
			httpMethod: "GET"
		)
	}
}
