//
//  StationsStore.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import Foundation
import RxComposableArchitecture
import Networking

typealias StationsState = (stations: [Station], favouritesStations: [Station])

enum StationsAction: Equatable {
	case autocomplete(String)
	case autocompleteResponse([Station])
	
	case favourites
	case favouritesResponse([Station])
	
	case none
}
