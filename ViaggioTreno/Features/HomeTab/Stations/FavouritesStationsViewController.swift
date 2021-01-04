//
//  FavouritesStationsViewController.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 04/01/21.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Styling
import RxComposableArchitecture
import Networking
import Caprice

class FavouritesStationsViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchStationsButton: UIButton!
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<FavouritesStationsSectionModel>!
	
	public var store: Store<StationsViewState, StationsViewAction>?
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		navigationController?.navigationBar.isHidden = true
		
		tableView.rowHeight = 85
		tableView.separatorColor = .clear
		
		registerTableViewCell(with: tableView, cell: StationsCell.self, reuseIdentifier: "StationsCell")
		
		setupDataSource()
		
		// MARK: - Load favourites
		
		store.send(.stations(.favourites))
		
		// MARK: - Bind dataSource
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.favouritesStations }
			.map { stations -> [FavouritesStationsSectionItem] in
				stations.map { station -> FavouritesStationsSectionItem in
					FavouritesStationsSectionItem(
						name: station.name
					)
				}
			}
			.map { (items: [FavouritesStationsSectionItem]) -> [FavouritesStationsSectionModel] in
				[FavouritesStationsSectionModel(model: "", items: items)]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<FavouritesStationsSectionModel>(
			animationConfiguration: AnimationConfiguration(insertAnimation: .right,
														   reloadAnimation: .none),
			configureCell: FavouritesStationsViewController.configureCell()
		)
	}
}
