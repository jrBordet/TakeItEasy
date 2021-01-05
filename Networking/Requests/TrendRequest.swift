//
//  TrendRequest.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation

import Foundation
import RxSwift

public struct Trend: Codable {
	public let numeroTreno: Int
	
	public let origine: String
	public let destinazione: String
	
	public let idOrigine: String
	public let idDestinazione: String
	
	public let compDurata: String
	public let compOrarioPartenzaZeroEffettivo: String
	public let compOrarioArrivoZeroEffettivo: String
	
	public let fermate: [TrainSection]
	
	public struct TrainSection: Codable, Equatable {
		public let stazione: String
		public let id: String
		public let ritardo: Int?
		public let partenza_teorica: TimeInterval?
		public let arrivo_teorico: TimeInterval?
		public let progressivo: Int?
	}
}

extension Trend: Equatable {
}

/// Perform an Http request to retrieve the train status
/// Example:
/// [Url ecample](http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno/andamentoTreno/S00137/11824)
/// Mon Nov 20 2017 17:30:00 GMT+0100
///
/// - Parameters:
///   - station: the origin station code. Example S01700
///   - train: the train number. Example 11824
/// - Returns: a Trend

public struct TrendRequest: APIRequest, CustomDebugStringConvertible {
	public var debugDescription: String {
		request.debugDescription
	}
	
	public typealias Response = Trend
	
	public var endpoint: String = "/andamentoTreno"
	
	private (set) var origin: String
	private (set) var train: String
	
	public var request: URLRequest? {
		guard let url = URL(string: "http://www.viaggiatreno.it/viaggiatrenonew/resteasy/viaggiatreno" + "\(endpoint)/\(origin)/\(train)") else {
			return nil
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		return request
	}
	
	public init(origin: String, train: String) {
		self.origin = origin
		self.train = train
	}
}
