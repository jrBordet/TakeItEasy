//
//  TrainSection+Store.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 22/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

public let trainSectionViewReducer: Reducer<TrainSectionViewState, TrainSectionViewAction, TrainSectionViewEnvironment> = combine(
	pullback(
		trainSectionReducer,
		value: \TrainSectionViewState.sectionState,
		action: /TrainSectionViewAction.section,
		environment: { $0 }
	)
)

public struct TrainSectionViewState: Equatable {
	public var selectedStation: Station?
	public var trainSections: [TrainSection]
	
	public init(
		selectedStation: Station?,
		trainSections: [TrainSection]
	) {
		self.selectedStation = selectedStation
		self.trainSections = trainSections
	}
	
	var sectionState: TrainSectionState {
		get { (self.selectedStation, self.trainSections) }
		set { (self.selectedStation, self.trainSections) = newValue }
	}
}

public enum TrainSectionViewAction: Equatable {
	case section(TrainSectionAction)
}

public typealias TrainSectionViewEnvironment = (String, String) -> Effect<[TrainSection]>

// MARk: - State

public typealias TrainSectionState = (selectedStation: Station?, trainSections: [TrainSection])

// MARk: - Action

public enum TrainSectionAction: Equatable {
	case trainSections(String, String)
	case trainSectionsResponse([TrainSection])
	
	case select(Station?)
		
	case none
}

// MARK: - Environment

public typealias TrainSectionEnvironment = (_ station: String, _ train: String) -> Effect<[TrainSection]>

func trainSectionReducer(
	state: inout TrainSectionState,
	action: TrainSectionAction,
	environment: TrainSectionEnvironment
) -> [Effect<TrainSectionAction>] {
	switch action {
	case let .trainSections(station, train):
		return [
			environment(station, train).map(TrainSectionAction.trainSectionsResponse)
		]
	case let .trainSectionsResponse(trainSections):
		state.trainSections = trainSections
		return []
	case .none:
		return []
	case let .select(station):
		state.selectedStation = station
		return [
			
		]
	}
}
