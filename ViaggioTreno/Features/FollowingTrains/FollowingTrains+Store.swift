//
//  FollowingTrains+Store.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 02/01/21.
//

import Foundation
import RxComposableArchitecture

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
	
	init(
		trains: [Train],
		selectedTrain: Train?
	) {
		self.selectedTrain = selectedTrain
		self.trains = trains
	}
	
	var trainsState: TrainsState {
		get {(
			self.trains,
			self.selectedTrain
		)}
		set {
			self.selectedTrain = newValue.selectedTrain
			self.trains = newValue.trains
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

typealias TrainsState = (trains: [Train], selectedTrain: Train?)

// MARK: - Action

enum TrainsAction: Equatable {
	case trains
	case trainsResponse([Train])
	
	case add(Train)
	case addResponse(Bool)
	
	case remove(Train)
	
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
	case .add(_):
		return []
	case .addResponse(_):
		return []
	case .remove(_):
		return []
	case .select(_):
		return []
	case .none:
		return []
	}
}
