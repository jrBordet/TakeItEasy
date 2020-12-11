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
					
					cell.stationNameLabel.text = value
					
					return cell
				case let .FavouriteStationSectionItem(value):
					guard let cell: StationCell = table.dequeueReusableCell(withIdentifier: "StationCell", for: idxPath) as? StationCell else {
						return UITableViewCell(style: .default, reuseIdentifier: nil)
					}
					
					cell.stationNameLabel.text = value
					
					return cell
				}
			}, titleForHeaderInSection: { dataSource, index in
				dataSource[index].title
			})
	}
}

extension StationsViewController {
	static func layoutMock() -> Observable<[StationSectionModel]> {
		.just([.StationSection(title: "",
							   items: [
								.FavouriteStationSectionItem("row 0"),
								.FavouriteStationSectionItem("row 1"),
								.FavouriteStationSectionItem("row 2")
							   ]),
			   .StationSection(title: "",
							   items: [
								.StationSectionItem("row 00"),
								.StationSectionItem("row 01"),
								.StationSectionItem("row 02")
							   ])
		])
	}
}

//https://jakubturek.com/uicollectionview-self-sizing-cells-animation/

public class StationsViewController: BaseViewController {
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!
	
	var dataSource: RxTableViewSectionedReloadDataSource<StationSectionModel> = StationsViewController.dataSource()
	
	private let disposeBag = DisposeBag()
	
	var temp = BehaviorRelay<[StationSectionModel]>(value: [
		.StationSection(title: "", items: [
			.FavouriteStationSectionItem("\(L10n.Media.confirm)")
		]),
		.StationSection(title: "", items: [
			.StationSectionItem("stations "),
		])
	])
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		//RxTableViewSectionedAnimatedDataSource
		
		// MARK: - styling
		title = L10n.Media.confirm
		
		self.tableView.rowHeight = 72
		self.tableView.separatorColor = .white
		
		self.registerTableViewCell(with: tableView, cell: StationCell.self, reuseIdentifier: "StationCell")
		
		// MARK: - bind dataSource
		
		func mock() -> [StationSectionModel] {
			[.StationSection(title: "", items: [
				.FavouriteStationSectionItem("row 0"),
				.FavouriteStationSectionItem("row 1"),
				.FavouriteStationSectionItem("row 2")
			]),
			.StationSection(title: "", items: [
				.StationSectionItem("row 00"),
				.StationSectionItem("row 01"),
				.StationSectionItem("row 02")
			])
			]
		}
		
		Observable<Int>
			.timer(.seconds(1), period: .seconds(3), scheduler: MainScheduler.instance)
			.subscribe (onNext: { v in				
				let value = self.temp.value
				
				self.temp.accept(value + [
					.StationSection(title: "", items: [
						.StationSectionItem("station 0\(v)"),
					])
				])
			}).disposed(by: disposeBag)
		
		
		StationsViewController
			.layoutMock()
//					temp
			.asObservable()
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
}
