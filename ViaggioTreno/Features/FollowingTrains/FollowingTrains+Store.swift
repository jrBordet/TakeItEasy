//
//  FollowingTrains+Store.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation
import RxComposableArchitecture
import Networking

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
	var trains: [Train]
	var selectedTrain: Train?
	var error: FollowingTrainsError?
	
	init(
		trains: [Train],
		selectedTrain: Train?,
		error: FollowingTrainsError?
	) {
		self.selectedTrain = selectedTrain
		self.trains = trains
		self.error = error
	}
	
	var trainsState: TrainsState {
		get {(
			self.trains,
			self.selectedTrain,
			self.error
		)}
		set {
			self.selectedTrain = newValue.selectedTrain
			self.trains = newValue.trains
			self.error = newValue.error
		}
	}
}

enum TrainsViewAction: Equatable {
	case trains(TrainsAction)
}

typealias TrainsViewEnvironment = (
	saveTrains: ([Train]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[Train]>
)

// MARK: - State

public enum FollowingTrainsError: Error, Equatable {
	case generic(String)
	case notSaved
}

typealias TrainsState = (trains: [Train], selectedTrain: Train?, error: FollowingTrainsError?)

// MARK: - Action

enum TrainsAction: Equatable {
	case trains
	case trainsResponse([Train])
	
	case trend(String, String) // originCode, trainNumber
	case trendResponse(Train, [TrainSection])
	
	case add(Train)
	case remove(Train)
	
	case updateResponse(Bool)
	
	case select(Train?)
	
	case none
}

// MARK: - Environment

typealias TrainsEnvironment = (
	saveTrains: ([Train]) -> Effect<Bool>,
	retrieveTrains: () -> Effect<[Train]>
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
		return []
	case let .add(train):
		guard (state.trains.filter { train ==  $0 }).isEmpty else {
			return []
		}
		
		state.trains.append(train)
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .updateResponse(response):
		guard response == true else {
			state.error = FollowingTrainsError.notSaved
			return []
		}
		return []
	case let .remove(train):
		guard (state.trains.filter { train ==  $0 }).isEmpty == false else {
			return []
		}
		
		state.trains = state.trains
			.map { $0.number == train.number ? nil : $0 }
			.compactMap { $0 }
		
		return [
			environment.saveTrains(state.trains).map(TrainsAction.updateResponse)
		]
	case let .select(train):
		state.selectedTrain = train
		return []
	case .none:
		return []
	case let .trend(origin, number):
		return []
	case let .trendResponse(train, sections):
		return []
	}
}
