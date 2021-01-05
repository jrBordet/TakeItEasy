//
//  FollowingTrainsItem.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 03/01/21.
//

import Foundation
import RxDataSources
import Caprice
import Networking

extension Trend: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(numeroTreno)\(origine)\(destinazione)"
	}
}

typealias FollowingTrainsListSectionModel = AnimatableSectionModel<String, FollowingTrainsSectionItem>

struct FollowingTrainsSectionItem {
	var originCode: String
	var trainNumber: String
	var originName: String
	var destinationName: String
	var originTime: String
	var destinationTime: String
}

extension FollowingTrainsSectionItem: Equatable {
}

extension FollowingTrainsSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(originTime)\(trainNumber)\(originCode)\(destinationTime)"
	}
}

// MARK: - Data Source Configuration

extension TrainsViewController {
	static func configureCell() -> RxTableViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>.ConfigureCell {
		return { _, table, idxPath, item in
			guard let cell = table.dequeueReusableCell(withIdentifier: "FollowingTrainCell", for: idxPath) as? FollowingTrainCell else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
			}
			
			cell.configure(
				with: item.originName,
				originTime: item.originTime,
				destination: item.destinationName,
				destinationTime: item.destinationTime
			)

			cell |> cellSelectionView()

			return cell
		}
	}
}
