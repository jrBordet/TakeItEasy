//
//  TravelsRequest.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 09/12/2020.
//

import Foundation
import RxSwift

public struct Departure: Codable {
	public let compNumeroTreno: String
	public let numeroTreno: Int
	public let destinazione: String
	public let compOrarioPartenza: String
	public let ritardo: Int
	public let compRitardo: [String]
	public let codOrigine: String
}

extension Departure: Equatable {
}

/// Perform an Http request to retrieve all departures from the give station id.
/// Example:
/// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/partenze/S01700/Mon%20Nov%2020%202017%2008:30:00%20GMT+0100%20)
/// Mon Nov 20 2017 17:30:00 GMT+0100 (ora solare Europa occidentale)
///
/// - Parameters:
///   - code: the station code. Example S01700
///   - date: the Date
/// - Returns: a collection of Departure

public struct DeparturesRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = [Departure]
	
	public var endpoint: String = "/partenze"
	
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

extension DeparturesRequest {
	public static func fetch(from station: String, date: Date = Date(), urlSession: URLSession = .shared) -> Observable<Self.Response> {
		Networking<DeparturesRequest>
			.departure(from: station, date: date)
			.json(with: urlSession)
	}
}

extension Networking where T == DeparturesRequest {
	public static func departure(from station: String, date: Date = Date()) -> Self {
		Self(
			API: T(code: station, date: date),
			httpMethod: "GET"
		)
	}
}

/// Create an encoded date with format EEE MMM dd yyyy HH:mm:ss GMT+0100
///
/// - Returns: a String representing the current date.
func encoded(_ date: Date) -> String {
	let dateFormatter = DateFormatter()
	
	dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")! as TimeZone
	dateFormatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss"
	dateFormatter.locale = Locale(identifier: "en_US")
	
	return (dateFormatter.string(from: date) + " GMT+0100").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
}
