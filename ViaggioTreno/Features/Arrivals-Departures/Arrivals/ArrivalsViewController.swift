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

struct CurrentTrain: Equatable {
	var number: String
	var name: String
	var status: String
	var originCode: String
}

struct ArrivalDepartureSectionItem {
	var number: String
	var train: Int
	var name: String
	var time: String
	var status: String
	var originCode: String
}

extension ArrivalDepartureSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return "\(number)\(String(train))\(time)\(originCode)"
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
		tableView.separatorColor = .clear
		
		registerTableViewCell(with: tableView, cell: ArrivalsDeparturesCell.self, reuseIdentifier: "ArrivalsDeparturesCell")
		
		setupDataSource()
		
		// MARK: - Select train

		tableView.rx
			.modelSelected(ArrivalDepartureSectionItem.self)
			.map {
				CurrentTrain(
					number: String($0.train),
					name: $0.number,
					status: $0.status,
					originCode: $0.originCode
				)
			}
			//.distinctUntilChanged()
			.bind(to: store.rx.selectTrain)
			.disposed(by: disposeBag)
		
		// MARK: - Bind dataSource
		
		func map(arrival: Arrival) -> ArrivalDepartureSectionItem {
			ArrivalDepartureSectionItem(
				number: arrival.compNumeroTreno,
				train: arrival.numeroTreno,
				name: arrival.origine,
				time: arrival.compOrarioArrivo,
				status: formatDelay(from: arrival.compRitardo),
				originCode: arrival.codOrigine
			)
		}
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.arrivals }
			.map { $0.map { map(arrival: $0) } }
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
			
			cell |> cellSelectionView()
			
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
