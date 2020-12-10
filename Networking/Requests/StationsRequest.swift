//
//  TravelRequest.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 07/12/2020.
//

import Foundation
import RxSwift

/// Retrieve stations by the given string
/// Example: [Url example](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/autocompletaStazione/mil)
/// Return a list of station as
//    MILANO CENTRALE|S01700
//    MILANO AFFORI|S01078
//    MILANO BOVISA FNM|S01642
/// - Parameter name: the name of the station
/// - Returns: a collection of Station

public struct StationsRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = [Station]
	
	public var endpoint: String = "/autocompletaStazione"
	
	private (set) var station: String
	
	public var request: URLRequest {
		guard let url = URL(string: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno" + "\(endpoint)/\(station)") else {
			fatalError()
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(station: String) {
		self.station = station
	}
}

extension StationsRequest {
	public static func autocompleteStation(with v: String, urlSession: URLSession = .shared) -> Observable<Self.Response> {
		Networking<StationsRequest>
			.autocompleteStation(with: v)
			.data(with: urlSession) { $0.parseStations() }
	}
}


