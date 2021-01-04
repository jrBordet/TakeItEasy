//
//  FavouritesStationsSectionItem.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 04/01/21.
//

import Foundation
import RxDataSources
import Caprice
import Networking

typealias FavouritesStationsSectionModel = AnimatableSectionModel<String, FavouritesStationsSectionItem>

struct FavouritesStationsSectionItem {
	var name: String
}

extension FavouritesStationsSectionItem: Equatable {
}

extension FavouritesStationsSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(name)"
	}
}

// MARK: - Data Source Configuration

extension FavouritesStationsViewController {
	static func configureCell() -> RxTableViewSectionedAnimatedDataSource<FavouritesStationsSectionModel>.ConfigureCell {
		return { _, table, idxPath, item in
			guard let cell = table.dequeueReusableCell(withIdentifier: "StationsCell", for: idxPath) as? StationsCell else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
			}
			
			cell.configure(with: item)
			
			cell |> cellSelectionView()
			
			return cell
		}
	}
}
