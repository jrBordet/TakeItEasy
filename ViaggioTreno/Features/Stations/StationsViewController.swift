//
//  StationsViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Styling
import RxComposableArchitecture
import Networking

enum StationSectionModel {
	case StationSection(title: String, items: [StationSectionItem])
}

enum StationSectionItem {
	case StationSectionItem(_ value: String)
	case FavouriteStationSectionItem(_ value: String)
}

extension StationSectionModel: SectionModelType {
	typealias Item = StationSectionItem
	
	var items: [StationSectionItem] {
		switch  self {
		case .StationSection(_, let items):
			return items.map { $0 }
		}
	}
	
	init(original: StationSectionModel, items: [Item]) {
		switch original {
		case .StationSection(let title, let items):
			self = .StationSection(title: title, items: items)
		}
	}
}

extension StationSectionModel {
	var title: String {
		switch self {
		case .StationSection(let title, _):
			return title
		}
	}
}

extension StationsViewController {
	static func dataSource() -> RxTableViewSectionedReloadDataSource<StationSectionModel> {
		RxTableViewSectionedReloadDataSource<StationSectionModel>(
			configureCell: { dataSource, table, idxPath, item in
				switch dataSource[idxPath] {
				case let .StationSectionItem(value):
					guard let cell: StationCell = table.dequeueReusableCell(withIdentifier: "StationCell", for: idxPath) as? StationCell else {
						return UITableViewCell(style: .default, reuseIdentifier: nil)
					}
					
					cell.stationNameLabel.text = value.capitalized
					
					return cell
				case let .FavouriteStationSectionItem(value):
					guard let cell: StationCell = table.dequeueReusableCell(withIdentifier: "StationCell", for: idxPath) as? StationCell else {
						return UITableViewCell(style: .default, reuseIdentifier: nil)
					}
					
					cell.stationNameLabel.text = value.capitalized
					
					return cell
				}
			}, titleForHeaderInSection: { dataSource, index in
				dataSource[index].title
			})
	}
}

//https://jakubturek.com/uicollectionview-self-sizing-cells-animation/

extension Store: ReactiveCompatible {}

public extension Reactive where Base: Store<StationsViewState, StationsViewAction> {
	
	var autocomplete: Binder<String?> {
		Binder(self.base) { store, value in
			guard let value = value else {
				return
			}

			store.send(.stations(.autocomplete(value)))
		}
	}
}

public class StationsViewController: BaseViewController {
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!
	
	var dataSource: RxTableViewSectionedReloadDataSource<StationSectionModel> = StationsViewController.dataSource()
	
	private let disposeBag = DisposeBag()
	
	public var store: Store<StationsViewState, StationsViewAction>?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
				
		guard let store = self.store else {
			return
		}
		
		// MARK: - styling
		title = L10n.Media.confirm
		
		tableView.rowHeight = 72
		tableView.separatorColor = .white
		
		registerTableViewCell(with: tableView, cell: StationCell.self, reuseIdentifier: "StationCell")
		
		searchBar.rx
			.searchButtonClicked
			.subscribe(onNext: { [weak self] in
				self?.searchBar.resignFirstResponder()
			}).disposed(by: disposeBag)
		
		// MARK: - autocomplete
		
		searchBar
			.rx
			.text
			.bind(to: store.rx.autocomplete)
			.disposed(by: disposeBag)

		// MARK: - bind dataSource
		
		store.send(.stations(.favourites))
		
		let favourites =
			store
			.value
			.map { $0.favouritesStations }
			.map { favourites -> [StationSectionModel] in
				let items = favourites.map { s -> StationSectionItem in
					.FavouriteStationSectionItem(s.name)
				}
				
				return [.StationSection(title: "", items: items)]
			}
		
		let stations =
			store
			.value
			.map { $0.stations }
			.map { stations -> [StationSectionModel] in
				let items = stations.map { s -> StationSectionItem in
					.StationSectionItem(s.name)
				}
				
				return [.StationSection(title: "", items: items)]
			}
		
		let sections = Observable<[StationSectionModel]>.combineLatest(favourites, stations) { $0 + $1 }
			
		sections
			.asObservable()
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
}
