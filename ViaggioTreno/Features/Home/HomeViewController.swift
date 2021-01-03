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
	@IBOutlet var searchStationsButton: UIButton!
	@IBOutlet var stationsCollectionView: UICollectionView!
	@IBOutlet var addLabel: UILabel!
	@IBOutlet var emptyStationsView: UIView!
	@IBOutlet var emptyStationsLabel: UILabel!
	
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
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.title = L10n.App.name
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.title = ""
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.isHidden = false
		self.navigationController?.navigationBar.tintColor = theme.primaryColor
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.primaryColor]
		
		guard let store = self.store else {
			return
		}
		
		// MARK: - styling
		
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
		
		// MARK: - Collection view layout
		
		stationsCollectionView.delegate = staionsCollectionViewDelegate
		
		// Do any additional setup after loading the view.
		
		let configureViewCell = HomeViewController.favouritesStationCollectionViewDataSource()
		
		let dataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: configureViewCell)
		
		register(with: stationsCollectionView, cell: FavouritesStationsCell.self, identifier: "FavouritesStationsCell")
		
		// MARK: - bind dataSource
		
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
			.bind(to: stationsCollectionView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
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

// MARK: - ConfigureCell

extension HomeViewController {
	static func favouritesStationCollectionViewDataSource() -> CollectionViewSectionedDataSource<HomeStationsSection>.ConfigureCell {
		return { dataSource, cv, idxPath, item in
			let cell = cv.dequeueReusableCell(withReuseIdentifier: "FavouritesStationsCell", for: idxPath) as! FavouritesStationsCell
			
			cell.configure(with: item)
			
			return cell
		}
	}
}

// MARK: - Data

struct HomeStationsSection {
	var header: String
	
	var stations: [Station]
	
	var updated: Date
	
	init(header: String, stations: [Item], updated: Date) {
		self.header = header
		self.stations = stations
		self.updated = updated
	}
}

// MARK: - Just extensions to say how to determine identity and how to determine is entity updated

extension HomeStationsSection: AnimatableSectionModelType {
	typealias Item = Station
	typealias Identity = String
	
	var identity: String {
		return header
	}
	
	var items: [Station] {
		return stations
	}
	
	init(original: HomeStationsSection, items: [Item]) {
		self = original
		self.stations = items
	}
}

extension HomeStationsSection: CustomDebugStringConvertible {
	var debugDescription: String {
		let interval = updated.timeIntervalSince1970
		let numbersDescription = stations.map { "\n\($0.name)" }.joined(separator: "")
		return "HomeStationsSection(header: \"\(self.header)\", numbers: \(numbersDescription)\n, updated: \(interval))"
	}
}

extension Station: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return id
	}
}

extension HomeStationsSection: Equatable {
	
}

func == (lhs: HomeStationsSection, rhs: HomeStationsSection) -> Bool {
	return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}
