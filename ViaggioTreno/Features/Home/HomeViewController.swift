//
//  HomeViewController.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 18/12/2020.
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
	var select: Binder<Station?> {
		Binder(self.base) { store, value in
			store.send(.favourites(.stations(.select(value))))
		}
	}
}

public class HomeViewController: BaseViewController {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var searchStationsButton: UIButton!
	@IBOutlet var stationsCollectionView: UICollectionView!
	@IBOutlet var addLabel: UILabel!
	@IBOutlet var emptyStationsView: UIView!
	@IBOutlet var emptyStationsLabel: UILabel!
	
	@IBOutlet var followingTrainTitleLabel: UILabel!
	@IBOutlet var followingTrainsCollectionView: UICollectionView!
	
	let theme: AppThemeMaterial = .theme
	
	private let disposeBag = DisposeBag()
	
	var store: Store<HomeViewState, HomeViewAction>?
	
	// MARK: - CollectionView layout
	
	private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0)
	
	private let itemsPerRow: CGFloat = 1
	
	let staionsCollectionViewDelegate = CollectionViewDelegate(
		itemsPerRow: 1,
		sectionInsets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0),
		size: CGSize(width: 65, height: 120)
	)
	
	let trainsCollectionViewDelegate = CollectionViewDelegate(
		itemsPerRow: 1,
		sectionInsets: UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0),
		size: CGSize(width: 320, height: 110)
	)
	
	// MARK: - Life cycle
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.title = L10n.App.name
		self.navigationController?.navigationBar.isHidden = true
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.title = ""
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.isHidden = true
		self.navigationController?.navigationBar.tintColor = theme.primaryColor
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.primaryColor]
		
		guard let store = self.store else {
			return
		}
		
		// MARK: - styling
		
		titleLabel
			|> theme.primaryLabel
			<> fontMedium(with: 17)
			<> textLabel("le mie stazioni")
			<> textColor(color: theme.primaryColor)
		
		followingTrainTitleLabel
			|> theme.primaryLabel
			<> fontMedium(with: 17)
			<> textLabel("treni seguiti")
			<> textColor(color: theme.primaryColor)
		
		addLabel
			|> theme.primaryLabel
			<> fontMedium(with: 17)
			<> textColor(color: .white)
			<> textLabel(L10n.App.Home.addStations)
			<> backgroundLabel(with: theme.primaryColor)
			<> rounded(with: 5)
		
		emptyStationsLabel
			|> theme.primaryLabel
			<> fontThin(with: 17)
			<> textLabel(L10n.App.Home.disclaimer)
		
		// MARK: - Collections view layout
		
		// MARK: stations
		
		stationsCollectionView.delegate = staionsCollectionViewDelegate
				
		let configureStationsCell = HomeViewController.favouritesStationCollectionViewDataSource()
		
		let stationsDataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: configureStationsCell)
		
		register(with: stationsCollectionView, cell: FavouritesStationsCell.self, identifier: "FavouritesStationsCell")
		
		// MARK: following trains
		
		followingTrainsCollectionView.delegate = trainsCollectionViewDelegate
		
		let configureTrainsCell = HomeViewController.configureFollowingTrainCell()
		
		let trainsDataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: configureTrainsCell)
		
		register(with: followingTrainsCollectionView, cell: FollowingTrainCell.self, identifier: "FollowingTrainCell")
		
		// MARK: - Trains bind dataSource
				
		store
			.value
			.map { $0.followingTrainsState.trains }
			.map { (trains: [FollowingTrain]) -> [FollowingTrain] in
				trains
			}
			.distinctUntilChanged()
			.map { trends -> [AnimatableSectionModel<String, FollowingTrainsSectionItem>] in
				[AnimatableSectionModel<String, FollowingTrainsSectionItem>(model: "following trains", items: trends.map{ t -> FollowingTrainsSectionItem in
					FollowingTrainsSectionItem(
						number: t.trainNumber,
						train: 120,
						name: "",
						time: "",
						status: "",
						originCode: t.originCode
					)
				})]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(followingTrainsCollectionView.rx.items(dataSource: trainsDataSource))
			.disposed(by: disposeBag)

		// MARK: - Stations bind dataSource
		
		store.send(.favourites(.stations(.favourites)))
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.favouritesStations.isEmpty == false }
			.bind(to: self.emptyStationsView.rx.isHidden)
			.disposed(by: disposeBag)
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.favouritesStations }
			.map { stations -> [HomeStationsSection] in
				[HomeStationsSection(header: "", stations: stations, updated: Date())]
			}
			.bind(to: stationsCollectionView.rx.items(dataSource: stationsDataSource))
			.disposed(by: disposeBag)
		
		// MARK: - Retrieve trains
		// TODO: - Retrieve trains

		// MARK: - Select stations
		
		stationsCollectionView.rx
			.modelSelected(Station.self)
			.bind(to: store.rx.select)
			.disposed(by: disposeBag)
		
		store
			.value
			.map { $0.favouritesStationsState.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { station in
				navigationLink(from: self, destination: Scene<ArrivalsDeparturesContainerViewController>(), completion: { vc in
					vc.store = store.view(
						value: { $0.arrivalsDeparturesState },
						action: { .arrivalsDepartures($0) }
					)
				}, isModal: false)
			})
			.disposed(by: disposeBag)
		
		// MARK: Search tap
		
		searchStationsButton.rx
			.tap
			.bind { [weak self] in
				guard let self = self else {
					return
				}
				
				navigationLink(from: self, destination: Scene<StationsViewController>(), completion: { vc in
					vc.store = store.view (
						value: { $0.favouritesStationsState },
						action: { .favourites($0) }
					)
				}, isModal: true)
			}.disposed(by: disposeBag)
	}
}
