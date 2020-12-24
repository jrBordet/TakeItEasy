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

// MARK: - Data

struct ArrivalDepartureSectionItem {
	var number: String
	var trainNumber: Int
	var name: String
	var time: String
	var status: String
}

extension ArrivalDepartureSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return number
	}
}

extension ArrivalDepartureSectionItem: Equatable { }

// MARK: - ViewController

class ArrivalsViewController: UIViewController {
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
		
		registerTableViewCell(with: tableView, cell: ArrivalsDeparturesCell.self, reuseIdentifier: "ArrivalsDeparturesCell")
		
		setupDataSource()
		
		// MARK: - Selected station
		
		store
			.value
			.map { $0.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.bind(to: store.rx.arrivals)
			.disposed(by: disposeBag)
		
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
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { trainNumber in
				dump(trainNumber)
			}).disposed(by: disposeBag)
		
		// MARK: - Bind dataSource
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.arrivals }
			.map { $0.map {
				ArrivalDepartureSectionItem(
					number: $0.compNumeroTreno,
					trainNumber: $0.numeroTreno,
					name: $0.origine,
					time: $0.compOrarioArrivo,
					status: formatDelay(from: $0.compRitardo))}
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

// MARK: - Data Source Configuration

extension ArrivalsViewController {
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

func formatDelay(from compRitardo: [String]) -> String {
	if Locale.current.identifier == "it_IT" {
		return compRitardo.first ?? ""
	} else {
		return compRitardo[1] // English
	}
}