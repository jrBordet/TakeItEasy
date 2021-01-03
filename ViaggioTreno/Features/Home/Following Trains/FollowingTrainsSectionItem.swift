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
// 	var dataSource: RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>!

extension Trend: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(numeroTreno)\(origine)\(destinazione)"
	}
}


typealias FollowingTrainsListSectionModel = AnimatableSectionModel<String, FollowingTrainsSectionItem>

struct FollowingTrainsSectionItem {
	var number: String
	var train: Int
	var name: String
	var time: String
	var status: String
	var originCode: String
}

extension FollowingTrainsSectionItem: Equatable {
}

extension FollowingTrainsSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(number)\(String(train))\(time)\(originCode)\(name)"
	}
}

// MARK: - Data Source Configuration

extension HomeViewController {
	static func configureFollowingTrainCell() -> RxCollectionViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>.ConfigureCell {
		return { _, cv, idxPath, item in
			guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "FollowingTrainCell", for: idxPath) as? FollowingTrainCell else {
				fatalError("unable to find FollowingTrainCell")
			}
			
			cell.originLabel.text = item.originCode.capitalized
//			cell.destinationLabel.text = item
			
			
//			cell.titleLabel.text = item.name.capitalized
//			cell.timeLabel.text = item.time
//			cell.statusLabel.text = item.status
			
			//cell |> cellSelectionView()
			
			return cell
		}
	}
//	var configureFollowingTrainCell: RxTableViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>.ConfigureCell {
//		return { _, table, idxPath, item in
//			guard let cell = table.dequeueReusableCell(withIdentifier: "FollowingTrainCell", for: idxPath) as? FollowingTrainCell else {
//				return UITableViewCell(style: .default, reuseIdentifier: nil)
//			}
//
////			cell.titleLabel.text = item.name.capitalized
////			cell.timeLabel.text = item.time
////			cell.statusLabel.text = item.status
//
//			cell |> cellSelectionView()
//
//			return cell
//		}
//	}
}
