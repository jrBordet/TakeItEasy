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

extension Reactive where Base: Store<HomeViewState, HomeViewAction> {
	var selectTrain: Binder<CurrentTrain?> {
		Binder(self.base) { store, value in
			store.send(.arrivalsDepartures(.sections(.section(.selectTrain(value)))))
			store.send(.arrivalsDepartures(.sections(.section(.select(Station(value?.originCode ?? "", name: ""))))))
		}
	}
	
	var originCode: Binder<Station?> {
		Binder(self.base) { store, value in
			store.send(.arrivalsDepartures(.sections(.section(.select(value)))))
		}
	}
	
}

class TrainsViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<FollowingTrainsListSectionModel>!
	
	public var store: Store<HomeViewState, HomeViewAction>?
	
	private let disposeBag = DisposeBag()
	
	// MARK: - Life cycle
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		guard let store = self.store else {
			return
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard let store = self.store else {
			return
		}
		
		store.send(.arrivalsDepartures(.sections(.section(.selectTrain(nil)))))
		store.send(.sections(.section(.select(nil))))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		store.send(.arrivalsDepartures(.sections(.section(.selectTrain(nil)))))
		store.send(.sections(.section(.select(nil))))
		
		self.navigationController?.navigationBar.isHidden = false
		self.navigationController?.navigationBar.tintColor = theme.primaryColor
		
		self.title = L10n.Trains.title
		
		navigationController?.navigationBar.isHidden = true
		
		tableView.rowHeight = 115
		tableView.separatorColor = .clear
		
		setupDataSource()
		
		registerTableViewCell(with: tableView, cell: FollowingTrainCell.self, reuseIdentifier: "FollowingTrainCell")
		
		store.send(.following(.trains(.trains)))
		
		store
			.value
			.map { $0.followingTrainsState.trains }
			.distinctUntilChanged()
			.map { trains -> [AnimatableSectionModel<String, FollowingTrainsSectionItem>] in
				[AnimatableSectionModel<String, FollowingTrainsSectionItem>(model: "", items: trains.map { t -> FollowingTrainsSectionItem in
					FollowingTrainsSectionItem(
						originCode: t.originCode,
						trainNumber: t.trainNumber,
						originName: t.originTitle ?? "",
						destinationName: t.destinationTile ?? "",
						originTime: t.originTime ?? "",
						destinationTime: t.destinationTime ?? ""
					)
				})]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		// MARK: - Select train
				
		tableView
			.rx
			.modelSelected(FollowingTrainsSectionItem.self)
			.map {
				CurrentTrain(
					number: $0.trainNumber,
					name: $0.originName,
					status: "",
					originCode: $0.originCode
				)
			}
			.bind(to: store.rx.selectTrain)
			.disposed(by: disposeBag)
		
		// MARK: - Train selected
				
		Observable<Bool>.zip(
			store.value.map { $0.train?.number },
			store.value.map { $0.train?.originCode }
		) { number, origincode -> Bool in
			guard zip(number, origincode) != nil else {
				return false
			}
			
			return true
		}
		.distinctUntilChanged()
		.filter { $0 }
		.subscribe(onNext: { [weak self] _ in
			guard let self = self else {
				return
			}
			
			navigationLink(from: self, destination: Scene<TrainSectionViewController>(), completion: { vc in
				vc.store = store.view(
					value: { $0.trainSectionsViewState },
					action: { .sections($0) }
				)
			}, isModal: false)
		}).disposed(by: disposeBag)
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
