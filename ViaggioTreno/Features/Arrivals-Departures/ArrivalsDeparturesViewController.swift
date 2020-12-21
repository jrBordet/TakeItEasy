//
//  ArrivalsDeparturesViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Styling
import RxComposableArchitecture
import Networking
import Caprice

struct ArrivalDepartureSectionItem {
	var number: String
	var name: String
	var time: String
}

extension ArrivalDepartureSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return number
	}
}

extension ArrivalDepartureSectionItem: Equatable { }

class ArrivalsDeparturesViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!

	typealias ArrivalsDeparturesListSectionModel = AnimatableSectionModel<String, ArrivalDepartureSectionItem>
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>!
	
	public var store: Store<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction>?
	
	private let disposeBag = DisposeBag()
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		tableView.rowHeight = 72
		tableView.separatorColor = .white
		
		// Do any additional setup after loading the view.
		registerTableViewCell(with: tableView, cell: ArrivalsDeparturesCell.self, reuseIdentifier: "ArrivalsDeparturesCell")
		
		setupDataSource()
		
		tableView
			.rx
			.setDelegate(self)
			.disposed(by: disposeBag)
		// S01700
		store.send(ArrivalsDeparturesViewAction.arrivalDepartures(ArrivalsDeparturesAction.arrivals("S01700")))
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.arrivals }
			.map { $0.map { ArrivalDepartureSectionItem(number: $0.compNumeroTreno ?? "", name: $0.origine ?? "", time: $0.compOrarioArrivo ?? "") } }
			.map { (items: [ArrivalDepartureSectionItem]) -> [ArrivalsDeparturesListSectionModel] in
				[ArrivalsDeparturesListSectionModel(model: "", items: items)]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>(
			animationConfiguration: AnimationConfiguration(insertAnimation: .top,
														   reloadAnimation: .none),
			configureCell: configureCell
		)
	}
}

extension ArrivalsDeparturesViewController: UITableViewDelegate {
	
}

// MARK: Data Source Configuration

extension ArrivalsDeparturesViewController {
	private var configureCell: RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>.ConfigureCell {
		return { _, table, idxPath, item in
			guard let cell = table.dequeueReusableCell(withIdentifier: "ArrivalsDeparturesCell", for: idxPath) as? ArrivalsDeparturesCell else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
			}
			
			cell.titleLabel.text = item.name.capitalized
			cell.timeLabel.text = item.time
			
			return cell
		}
	}
}
