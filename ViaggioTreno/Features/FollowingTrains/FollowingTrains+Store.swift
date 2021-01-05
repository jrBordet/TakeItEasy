//
//  FollowingTrains+Store.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation
import RxComposableArchitecture
import Networking
import Caprice

struct Train: Equatable {
	var number: String
	var status: String
	var originCode: String
	var from: Station
	var to: Station
	var duration: String
	
	struct Station: Equatable {
		var time: TimeInterval
		var name: String
	}
}

extension Train {
	static var sample = Self(
		number: "11824",
		status: "on time",
		originCode: "S00137",
		from: Train.Station(time: 1609577700000, name: "AOSTA"),
		to: Train.Station(time: 1609581960000, name: "IVREA"),
		duration: "1:11"
	)
}

let trainsViewReducer: Reducer<TrainsViewState, TrainsViewAction, TrainsViewEnvironment> = combine(
	pullback(
		trainsReducer,
		value: \TrainsViewState.trainsState,
		action: /TrainsViewAction.trains,
		environment: { $0 }
	)
)

struct TrainsViewState: Equatable {
	var trains: [FollowingTrain]
	var trends: [Trend]
	var selectedTrend: Trend?
	var error: FollowingTrainsError?
	var selectedTrain: FollowingTrain?
	var isFollowing: Bool
	
	init(
		trains: [FollowingTrain],
		trends: [Trend],
		selectedTrend: Trend?,
		error: FollowingTrainsError?,
		selectedTrain: FollowingTrain?,
		isFollowing: Bool
	) {
		self.trains = trains
		self.selectedTrend = selectedTrend
		self.trends = trends
		self.error = error
		self.selectedTrain = selectedTrain
		self.isFollowing = isFollowing
	}
	
	var trainsState: TrainsState {
		get {(
			self.trains,
			self.trends,
			self.selectedTrend,
			self.error,
			self.selectedTrain,
			self.isFollowing
		)}
		set {
			self.trains = newValue.trains
			self.selectedTrend = newValue.selectedTrend
			self.trends = newValue.trends
			self.error = newValue.error
			self.selectedTrain = newValue.selectedTrain
			self.isFollowing = newValue.isFollowing
		}
	}
}

enum TrainsViewAction: Equatable {
	case trains(TrainsAction)
}

typealias TrainsViewEnvironment = (
	saveTrains: ([FollowingTrain]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[FollowingTrain]>,
	retrieveTrend: (String, String) -> Effect<Trend?>
)

// MARK: - State

public enum FollowingTrainsError: Error, Equatable {
	case generic(String)
	case notSaved
}

typealias TrainsState = (trains: [FollowingTrain], trends: [Trend], selectedTrend: Trend?, error: FollowingTrainsError?, selectedTrain: FollowingTrain?, isFollowing: Bool)

struct FollowingTrain {
	var originCode: String
	var trainNumber: String
	var originTitle: String?
	var destinationTile: String?
	var duration: String?
	var originTime: String?
	var destinationTime: String?
}

extension FollowingTrain: Equatable {
}

extension FollowingTrain: Codable {
}

extension FollowingTrain {
	static var sample_aosta_ivrea = Self(
		originCode: "S00137", trainNumber: "2776"
	)
	
	static var sample_milano_torino = Self(
		originCode: "S09823", trainNumber: "9516"
	)
}

// MARK: - Action

enum TrainsAction: Equatable {
	case trains
	case trainsResponse([FollowingTrain])
	
	case trend(String, String) // originCode, trainNumber
	case trendResponse(Trend?)
	
	case follow(FollowingTrain)
	case remove(FollowingTrain)
	
	case updateResponse(Bool) // persistence effect response
	
	case select(Trend?)
	
	case selectTrain(FollowingTrain?)
}

// MARK: - Environment

typealias TrainsEnvironment = (
	saveTrains: ([FollowingTrain]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[FollowingTrain]>,
	retrieveTrend: (String, String) -> Effect<Trend?>
)

func trainsReducer(
	state: inout TrainsState,
	action: TrainsAction,
	environment: TrainsEnvironment
) -> [Effect<TrainsAction>] {
	switch action {
	case .trains:
		return [
			environment.retrieveTrains().map(TrainsAction.trainsResponse)
		]
	case let .trainsResponse(result):
		state.trains = result
		
		guard let train = state.selectedTrain else {
			state.isFollowing = false
			return []
		}
			
		state.isFollowing = (result.filter { train.originCode == $0.originCode && train.trainNumber == $0.trainNumber }).isEmpty == false
		
		return []
	case let .follow(train):
		guard (state.trains.filter { train.originCode ==  $0.originCode && train.trainNumber == $0.trainNumber }).isEmpty == false else {
			// start follow
			state.isFollowing = true
			
			return [
				Effect.sync { }.map { TrainsAction.trend(train.originCode, train.trainNumber) }
			]
		}
		
		// stop follow
		state.isFollowing = false
		
		let result = state.trains.map { t -> FollowingTrain? in
			guard t.originCode == train.originCode && t.trainNumber == train.trainNumber else {
				return t
			}
			
			return nil
		}
		
		state.trains = result.compactMap { $0 }
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .updateResponse(response):
		guard response == true else {
			state.error = .notSaved
			return []
		}
		return []
	case let .remove(train):
		guard (state.trains.filter { train.originCode ==  $0.originCode && train.trainNumber == $0.trainNumber }).isEmpty == false else {
			return []
		}
		
		state.trains = state.trains
			.map { train.originCode ==  $0.originCode && $0.trainNumber == train.trainNumber ? nil : $0 }
			.compactMap { $0 }
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .select(trend):
		state.selectedTrend = trend
		return []
	case let .trend(origin, number):
		state.selectedTrain = FollowingTrain(originCode: origin, trainNumber: number)
		
		return [
			environment.retrieveTrend(origin, number).map(TrainsAction.trendResponse)
		]
	case let .trendResponse(trend):
		guard let trend = trend else {
			return []
		}
		
		// update current train with trend informations
		guard let selectedTrain = state.selectedTrain else {
			return []
		}
		
		let train = selectedTrain
			|> \FollowingTrain.originTitle *~ trend.origine
			|> \FollowingTrain.destinationTile *~ trend.destinazione
			|> \FollowingTrain.destinationTime *~ trend.compOrarioArrivoZeroEffettivo
			|> \FollowingTrain.originTime *~ trend.compOrarioPartenzaZeroEffettivo
		
		state.trains.append(train)
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .selectTrain(train):
		return []
	}
}
