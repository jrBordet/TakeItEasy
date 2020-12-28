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
	public let origine: String
	public let compOrarioArrivo: String
	public let compNumeroTreno: String
	public let compRitardo: [String]
	public let codOrigine: String
}

extension Arrival: Equatable {
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
