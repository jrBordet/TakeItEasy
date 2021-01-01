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
	
	public var request: URLRequest? {
		guard let url = URL(string: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno" + "\(endpoint)/\(station.trimSpaces.emojilessStringWithSubstitution)") else {
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(station: String) {
		self.station = station
	}
}

public struct Station: Codable, Equatable {
	public let id: String
	public let name: String
	
	public init(_ id: String, name: String) {
		self.id = id
		self.name = name
	}
}

extension Station {
	public static var milano: [Station] { [
			Station("S05188", name: "MODENA PIAZZA MANZONI"),
			Station("S05997", name: "MEZZOLARA")
		]
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
				
				return Station(String(v[1]).trimSpaces, name: String(v[0]))
			}
			.compactMap { $0 }
			.filter { station -> Bool in
				station.id != "S00143" && station.id != "S00146"
			}
	}
}
