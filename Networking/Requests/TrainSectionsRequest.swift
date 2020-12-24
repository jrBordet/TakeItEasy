//
//  TrainSectionsRequest.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 10/12/2020.
//

import Foundation
import RxSwift

public struct TrainSection: Codable, Equatable {
	public let last: Bool
	public let stazioneCorrente: Bool
	public let id: String
	public let stazione: String
	public let fermata: TrainStop
	
	public struct TrainStop: Codable, Equatable {
		public let programmata: TimeInterval?
		public let effettiva: TimeInterval?
		public let ritardo: Int?
		public let partenza_teorica: TimeInterval?
		public let arrivo_teorico: TimeInterval?
		public let progressivo: Int? // delay
		public let partenzaReale: TimeInterval?
	}
}

/// Perform an Http request to retrieve all sections from the departure code and train code.
/// Example:
/// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/tratteCanvas/S06000/666)
///
/// - Parameters:
///   - codeDeparture: the station code. Example S06000
///   - codeTrain: the station code. Example 666
/// - Returns: a collection of TravelDetail

public struct TrainSectionsRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = [TrainSection]
	
	public var endpoint: String = "/tratteCanvas"
	
	private (set) var station: String
	private (set) var train: String
	
	public var request: URLRequest {
		guard let url = URL(string: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno" + "\(endpoint)/\(station)/\(train)") else {
			fatalError()
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(station: String, train: String) {
		self.station = station
		self.train = train
	}
}

extension TrainSectionsRequest {
	public static func fetch(from station: String, train: String, urlSession: URLSession = .shared) -> Observable<Self.Response> {
		Networking<Self>
			.sections(from: station, train: train)
			.json(with: urlSession)
	}
	
	public static func mock(_ data: Data) -> Self.Response {
		Networking<Self>.mock(data)
	}
}

extension Networking where T == TrainSectionsRequest {
	public static func sections(from station: String, train: String) -> Self {
		Self(
			API: T(station: station, train: train),
			httpMethod: "GET"
		)
	}
}
