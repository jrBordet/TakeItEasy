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
import Caprice

enum StationSectionModel {
	case StationSection(title: String, items: [StationSectionItem])
}

extension StationSectionModel {
	static var empty: [StationSectionModel] = [.StationSection(title: "", items: [StationSectionItem.EmptysectionItem])]
}

enum StationSectionItem: Equatable {
	case StationSectionItem(_ value: Station)
	case FavouriteStationSectionItem(_ value: Station)
	case EmptysectionItem
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
					
					cell.stationNameLabel.text = value.name.capitalized
					
					return cell
				case let .FavouriteStationSectionItem(value):
					guard let cell: StationCell = table.dequeueReusableCell(withIdentifier: "StationCell", for: idxPath) as? StationCell else {
						return UITableViewCell(style: .default, reuseIdentifier: nil)
					}
					
					cell.stationNameLabel.text = value.name.capitalized
					
					return cell
				case .EmptysectionItem:
					return UITableViewCell(style: .default, reuseIdentifier: nil)
				}
			}, titleForHeaderInSection: { dataSource, index in
				guard dataSource[index].items.count > 0 else {
					return nil
				}
				
				return dataSource[index].title
			})
	}
}

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
	
	var addFavorite: Binder<Station?> {
		Binder(self.base) { store, value in
			guard let value = value else {
				return
			}
			
			store.send(.stations(.addFavorite(value)))
		}
	}
	
	var removeFavorite: Binder<Station?> {
		Binder(self.base) { store, value in
			guard let value = value else {
				return
			}
			
			store.send(.stations(.removeFavourite(value)))
		}
	}
	
	var select: Binder<Station?> {
		Binder(self.base) { store, value in
			store.send(.stations(.select(value)))
		}
	}
}

public class StationsViewController: BaseViewController {
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView?
	
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var closeContainer: UIView!
	
	var dataSource: RxTableViewSectionedReloadDataSource<StationSectionModel> = StationsViewController.dataSource()
	
	private let disposeBag = DisposeBag()
	
	public var store: Store<StationsViewState, StationsViewAction>?
	
	let theme: AppThemeMaterial = .theme
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		guard
			let store = self.store,
			let tableView = self.tableView else {
			return
		}
		
		// MARK: - styling
		title = L10n.Stations.title
		
		tableView.tableFooterView = UIView()
		tableView.separatorStyle = .none
		
		searchBar.placeholder = L10n.Stations.searchbar
		
		closeContainer |> backgroundColor(with: theme.primaryColor)
		
		closeButton
			|> {
				$0?.setTitleColor(.white, for: .normal)
				$0?.setTitle(L10n.App.Common.x, for: .normal)
			}

		if #available(iOS 13.0, *) {
			searchBar.searchTextField |> fontTextField(with: 15)
			closeContainer.isHidden = true
		} else {
			// Fallback on earlier versions
			closeContainer.isHidden = false
		}
		
		tableView.rowHeight = 72
		tableView.separatorColor = .white
		
		registerTableViewCell(with: tableView, cell: StationCell.self, reuseIdentifier: "StationCell")
		tableView.register(UINib(nibName: "StationsSectionHeader", bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: "StationsSectionHeader")
		
		searchBar.rx
			.searchButtonClicked
			.subscribe(onNext: { [weak self] in
				self?.searchBar.resignFirstResponder()
			}).disposed(by: disposeBag)
		
		tableView
			.rx
			.setDelegate(self)
			.disposed(by: disposeBag)
		
		// MARK: - Model Selected
		
		let modelSelected =
			tableView.rx
			.modelSelected(StationSectionItem.self)
			.share()
		
		// MARK: - Close
		
		closeButton.rx.tap.bind { [weak self] in
			self?.dismiss(animated: true, completion: nil)
		}.disposed(by: disposeBag)
		
		// MARK: - Can edit
		
		dataSource.canEditRowAtIndexPath = { dataSource, idxPath  in
			switch dataSource[idxPath] {
			case .FavouriteStationSectionItem:
				return true
			case .EmptysectionItem, .StationSectionItem:
				return false
			}
		}
		
		tableView.rx
			.modelDeleted(StationSectionItem.self)
			.map { station -> Station? in
				guard case let .FavouriteStationSectionItem(value) = station else {
					return  nil
				}
				
				return value
			}
			.bind(to: store.rx.removeFavorite)
			.disposed(by: disposeBag)

		// MARK: - Select a result
		
		modelSelected
			.map { station -> Station? in
				guard case let .StationSectionItem(value) = station else {
					return  nil
				}

				return value
			}
			.bind(to: store.rx.addFavorite)
			.disposed(by: disposeBag)
		
		// MARK: - autocomplete
		
		searchBar.rx
			.text
			.bind(to: store.rx.autocomplete)
			.disposed(by: disposeBag)
		
		// MARK: - bind dataSource
		
		store.send(.stations(.favourites))
		
		let favorites =
			store
			.value
			.map { $0.favouritesStations }
			.map { favourites -> [StationSectionModel] in
				guard favourites.count > 0 else {
					return StationSectionModel.empty
				}
				
				return [.StationSection(title: "", items: favourites.map { s -> StationSectionItem in
					.FavouriteStationSectionItem(s)
				})]
			}
		
		let stations =
			store
			.value
			.map { $0.stations }
			.map { stations -> [StationSectionModel] in
				guard stations.count > 0 else {
					return StationSectionModel.empty
				}
				
				return [.StationSection(title: "", items:  stations.map { s -> StationSectionItem in
					.StationSectionItem(s)
				})]
			}
		
		let sections = Observable<[StationSectionModel]>.combineLatest(favorites, stations) { favorites, stations in
			guard let item = favorites.first?.items.first else {
				return stations
			}
			
			guard case .EmptysectionItem = item else {
				return  favorites + stations
			}
			
			return stations
		}
		
		sections
			.asObservable()
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
}

// MARK: - UITableViewDelegate

extension StationsViewController: UITableViewDelegate {
	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StationsSectionHeader") as? StationsSectionHeader else {
			return nil
		}
		
		switch dataSource[IndexPath(row: 0, section: section)] {
		case .StationSectionItem:
			header.sectionLabel.text = L10n.Stations.Header.results
		case .FavouriteStationSectionItem:
			header.sectionLabel.text = L10n.Stations.Header.favourites
		case .EmptysectionItem:
			return nil
		}
		
		return header
	}
	
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch dataSource[IndexPath(row: 0, section: section)] {
		case .FavouriteStationSectionItem, .StationSectionItem:
			return 44
		case .EmptysectionItem:
			return .zero
		}
	}
}
