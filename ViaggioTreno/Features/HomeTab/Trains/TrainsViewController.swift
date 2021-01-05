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
		
		tableView.rowHeight = 200
		tableView.separatorColor = .clear
		
		setupDataSource()
		
		registerTableViewCell(with: tableView, cell: FollowingTrainCell.self, reuseIdentifier: "FollowingTrainCell")
		
		store.send(.following(.trains(.trains)))
				
		store
			.value
			.map { $0.followingTrainsState.trains }
			.map { (trains: [FollowingTrain]) -> [FollowingTrain] in
				trains
			}
			.distinctUntilChanged()
			.map { trends -> [AnimatableSectionModel<String, FollowingTrainsSectionItem>] in
				[AnimatableSectionModel<String, FollowingTrainsSectionItem>(model: "following trains", items: trends.map{ t -> FollowingTrainsSectionItem in
					FollowingTrainsSectionItem(
						number: t.originTitle ?? "",
						train: 120,
						name: t.originTitle ?? "",
						time: "",
						status: "",
						originCode: t.originTitle ?? ""
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
