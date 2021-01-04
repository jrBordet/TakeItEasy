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
import SceneBuilder

extension Reactive where Base: Store<StationsViewState, StationsViewAction> {
	var selectStation: Binder<FavouritesStationsSectionItem> {
		Binder(self.base) { store, value in
			store.send(StationsViewAction.stations(StationsAction.select(Station.milano.first!)))
		}
	}
}

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
		
		searchStationsButton
			|> theme.primaryButton
			<> { $0.setTitle(L10n.App.Home.addStations, for: .normal) }
		
		// MARK: - Search
		
		searchStationsButton.rx
			.tap
			.bind { [weak self] in
				guard let self = self else {
					return
				}
				
				navigationLink(from: self, destination: Scene<StationsViewController>(), completion: { vc in
//					vc.store = store.view (
//						value: { $0.favouritesStationsState },
//						action: { .favourites($0) }
//					)
				}, isModal: true)
			}.disposed(by: disposeBag)
		
		// MARK: - Load favourites
		
		store.send(.stations(.favourites))
		
		// MARK: - Select station
		
		tableView
			.rx
			.modelSelected(FavouritesStationsSectionItem.self)
			.bind(to: store.rx.selectStation)
			.disposed(by: disposeBag)
		
		store
			.value
			.map { $0.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { station in
				navigationLink(from: self, destination: Scene<ArrivalsDeparturesContainerViewController>(), completion: { vc in
//					vc.store = store.view(
//						value: { $0.arrivalsDeparturesState },
//						action: { .arrivalsDepartures($0) }
//					)
					
//					store.view {
//						$0
//					}, action: {
//						.stations($0)
//					}

//					vc.store = store.view(
//						value: { $0. },
//						action: { .arrivalsDepartures($0) }
//					)
				}, isModal: false)
			})
			.disposed(by: disposeBag)
		
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
