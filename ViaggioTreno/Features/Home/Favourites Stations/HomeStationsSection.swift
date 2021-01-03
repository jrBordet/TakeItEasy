//
//  HomeStationsSection.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 03/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Networking

// MARK: - Data

struct HomeStationsSection {
	var header: String
	
	var stations: [Station]
	
	var updated: Date
	
	init(header: String, stations: [Item], updated: Date) {
		self.header = header
		self.stations = stations
		self.updated = updated
	}
}

// MARK: - Just extensions to say how to determine identity and how to determine is entity updated

extension HomeStationsSection: AnimatableSectionModelType {
	typealias Item = Station
	typealias Identity = String
	
	var identity: String {
		return header
	}
	
	var items: [Station] {
		return stations
	}
	
	init(original: HomeStationsSection, items: [Item]) {
		self = original
		self.stations = items
	}
}

extension HomeStationsSection: CustomDebugStringConvertible {
	var debugDescription: String {
		let interval = updated.timeIntervalSince1970
		let numbersDescription = stations.map { "\n\($0.name)" }.joined(separator: "")
		return "HomeStationsSection(header: \"\(self.header)\", numbers: \(numbersDescription)\n, updated: \(interval))"
	}
}

extension Station: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return id
	}
}

extension HomeStationsSection: Equatable {
	
}

func == (lhs: HomeStationsSection, rhs: HomeStationsSection) -> Bool {
	return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}

// MARK: - ConfigureCell

extension HomeViewController {
	static func favouritesStationCollectionViewDataSource() -> CollectionViewSectionedDataSource<HomeStationsSection>.ConfigureCell {
		return { dataSource, cv, idxPath, item in
			let cell = cv.dequeueReusableCell(withReuseIdentifier: "FavouritesStationsCell", for: idxPath) as! FavouritesStationsCell
			
			cell.configure(with: item)
			
			return cell
		}
	}
}
