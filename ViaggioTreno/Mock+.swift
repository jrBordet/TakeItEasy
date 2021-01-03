//
//  Mock+.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 23/12/2020.
//

import Foundation

extension Data {
	static var train_sections: Data? {
		data(from: "train_sections", type: ".json")
	}
	
	static var train_sections_broken: Data? {
		data(from: "train_sections_broken", type: ".json")
	}
	
	static var arrivals: Data? {
		data(from: "arrivals", type: ".json")
	}
	
	static var arrivals_broken: Data? {
		data(from: "arrivals_broken", type: ".json")
	}
	
	static var departures: Data? {
		data(from: "departures", type: ".json")
	}
	
	static var departures_broken: Data? {
		data(from: "departures_broken", type: ".json")
	}
	
	static var stations_broken: Data? {
		data(from: "stations_broken", type: ".txt")
	}
	
	static var stations: Data? {
		data(from: "stations", type: ".txt")
	}
	
	static var trend: Data? {
		data(from: "trend", type: ".json")
	}
	
	static var trend_broken: Data? {
		data(from: "trend_broken", type: ".json")
	}
	
	static var trend_milano_centrale: Data? {
		data(from: "trend_milano_centrale", type: ".json")
	}
	
	static var trend_torino_p_nuova_reggio_calabria: Data? {
		data(from: "trend_torino_p_nuova_reggio_calabria", type: ".json")
	}
	
	private static func data(from file: String, type: String) -> Data? {
		Bundle.main
			.path(forResource: file, ofType: type)
			.map (URL.init(fileURLWithPath:))
			.flatMap { try? Data(contentsOf: $0) }
	}
}
