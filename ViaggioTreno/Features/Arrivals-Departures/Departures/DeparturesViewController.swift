//
//  DeparturesViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 22/12/2020.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Styling
import RxComposableArchitecture
import Networking
import Caprice

extension Reactive where Base: Store<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction> {
	var selectStation: Binder<Station?> {
		Binder(self.base) { store, value in
			store.send(.arrivalDepartures(.select(value)))
		}
	}
	
	var selectTrain: Binder<Int?> {
		Binder(self.base) { store, value in
 			store.send(.arrivalDepartures(.selectTrain(value)))
		}
	}
	
	var departures: Binder<Station> {
		Binder(self.base) { store, value in
			store.send(.arrivalDepartures(.departures(value.id)))
		}
	}
	
	var arrivals: Binder<Station> {
		Binder(self.base) { store, value in
			store.send(.arrivalDepartures(.arrivals(value.id)))
		}
	}
}

class DeparturesViewController: BaseViewController {
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
		
		tableView.rowHeight = 85
		tableView.separatorColor = .white
		
		// Do any additional setup after loading the view.
		registerTableViewCell(with: tableView, cell: ArrivalsDeparturesCell.self, reuseIdentifier: "ArrivalsDeparturesCell")
		
		setupDataSource()
		
		// MARK: - Selected station
		
		store
			.value
			.map { $0.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.bind(to: store.rx.departures)
			.disposed(by: disposeBag)
		
//		store
//			.value
//			.map { $0.favouritesStationsState.selectedStation }
//			.distinctUntilChanged()
//			.ignoreNil()
//			.subscribe(onNext: { station in
//				navigationLink(from: self, destination: Scene<ArrivalsDeparturesContainerViewController>(), completion: { vc in
//					vc.store = store.view(
//						value: { $0.arrivalsDeparturesState },
//						action: { .arrivalsDepartures($0) }
//					)
//				}, isModal: false)
//			})
//			.disposed(by: disposeBag)
		
		// MARK: - Select section
		
		tableView.rx
			.modelSelected(ArrivalDepartureSectionItem.self)
			.map { $0.trainNumber }
			.distinctUntilChanged()
			.bind(to: store.rx.selectTrain)
			.disposed(by: disposeBag)
		
		store
			.value
			.map { $0.trainNumber }
			.debug("[\(self.debugDescription)]", trimOutput: false)
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { trainNumber in
				dump(trainNumber)
			}).disposed(by: disposeBag)
		
		// MARK: - Bind dataSource
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.departures }
			.map { $0.map {
				ArrivalDepartureSectionItem(
					number: $0.compNumeroTreno,
					trainNumber: $0.numeroTreno,
					name: $0.destinazione,
					time: $0.compOrarioPartenza,
					status: formatDelay(from: $0.compRitardo)
				)}
			}
			.map { (items: [ArrivalDepartureSectionItem]) -> [ArrivalsDeparturesListSectionModel] in
				[ArrivalsDeparturesListSectionModel(model: "", items: items)]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>(
			animationConfiguration: AnimationConfiguration(insertAnimation: .right,
														   reloadAnimation: .none),
			configureCell: configureCell
		)
	}
}

// MARK: Data Source Configuration

extension DeparturesViewController {
	private var configureCell: RxTableViewSectionedAnimatedDataSource<ArrivalsDeparturesListSectionModel>.ConfigureCell {
		return { _, table, idxPath, item in
			guard let cell = table.dequeueReusableCell(withIdentifier: "ArrivalsDeparturesCell", for: idxPath) as? ArrivalsDeparturesCell else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
			}
			
			cell.titleLabel.text = item.name.capitalized
			cell.timeLabel.text = item.time
			cell.statusLabel.text = item.status
			
			return cell
		}
	}
}
