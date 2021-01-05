//
//  TrainsViewController.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 04/01/21.
//

import UIKit
import RxSwift
import RxCocoa
import SceneBuilder
import RxDataSources
import Networking
import Styling
import Caprice
import RxComposableArchitecture

class TrainsViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>!
	
	public var store: Store<HomeViewState, HomeViewAction>?
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		navigationController?.navigationBar.isHidden = true
		
		tableView.rowHeight = 115
		tableView.separatorColor = .clear
		
		setupDataSource()
		
		registerTableViewCell(with: tableView, cell: FollowingTrainCell.self, reuseIdentifier: "FollowingTrainCell")
		
		store.send(.following(.trains(.trains)))
				
		store
			.value
			.map { $0.followingTrainsState.trains }
			.distinctUntilChanged()
			.map { trains -> [AnimatableSectionModel<String, FollowingTrainsSectionItem>] in
				[AnimatableSectionModel<String, FollowingTrainsSectionItem>(model: "", items: trains.map { t -> FollowingTrainsSectionItem in
					FollowingTrainsSectionItem(
						originCode: t.originCode,
						trainNumber: t.trainNumber,
						originName: t.originTitle ?? "",
						destinationName: t.destinationTile ?? "",
						originTime: t.originTime ?? "",
						destinationTime: t.destinationTime ?? ""
					)
				})]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>(
			animationConfiguration: AnimationConfiguration(
				insertAnimation: .right,
				reloadAnimation: .none
			),
			configureCell: TrainsViewController.configureCell()
		)
	}
	
}
