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

public class HomeViewController: BaseViewController {
	@IBOutlet var searchStationsButton: UIButton!
	@IBOutlet var stationsCollectionView: UICollectionView!
	@IBOutlet var addLabel: UILabel!
	@IBOutlet var emptyStationsView: UIView!
	@IBOutlet var emptyStationsLabel: UILabel!
	
	let theme: AppThemeMaterial = .theme
	
	private let disposeBag = DisposeBag()
	
	public var store: Store<HomeViewState, HomeViewAction>?
	
	// MARK: - CollectionView layout
	
	private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0)
	
	private let itemsPerRow: CGFloat = 1
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		self.navigationController?.navigationBar.isHidden = true
		
		// MARK: - styling
		
		addLabel
			|> theme.primaryLabel
			<> fontMedium(with: 17)
			<> textColor(color: theme.primaryColor)
			<> textLabel(L10n.App.Home.addStations)
		
		emptyStationsLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> textLabel(L10n.App.Home.disclaimer)
		
		// MARK: - Collection view layout
		
		stationsCollectionView.delegate = self
		
		// Do any additional setup after loading the view.
		
		let configureViewCell = HomeViewController.favouritesStationCollectionViewDataSource()
		
		let dataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: configureViewCell)
		
		register(with: stationsCollectionView, cell: FavouritesStationsCell.self, identifier: "FavouritesStationsCell")
		
		// MARK: - bind dataSource
		
		store.send(HomeViewAction.favourites(StationsViewAction.stations(.favourites)))
	
		stationsCollectionView.rx
			.modelSelected(Station.self)
			.subscribe(onNext: {
				dump($0)
			}).disposed(by: disposeBag)
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.favouritesStations.favouritesStations.isEmpty == false }
			.bind(to: self.emptyStationsView.rx.isHidden)
			.disposed(by: disposeBag)
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.favouritesStations }
			.distinctUntilChanged()
			.map { stations -> [HomeStationsSection] in
				[HomeStationsSection(header: "", numbers: stations.favouritesStations, updated: Date())]
			}
			.bind(to: stationsCollectionView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
		
		// MARK: Search tap
		
		searchStationsButton.rx
			.tap
			.bind { [weak self] in
				guard let self = self else {
					return
				}
				
				navigationLink(from: self, destination: Scene<StationsViewController>(), completion: { vc in
					vc.store =
						store.view (
							value: { $0.favouritesStations },
							action: { .favourites($0) }
						)
				}, isModal: true)
			}.disposed(by: disposeBag)
	}
	
}

// MARK: - Collection View Flow Layout Delegate

extension HomeViewController: UICollectionViewDelegateFlowLayout {
	
	public func collectionView(_ collectionView: UICollectionView,
							   layout collectionViewLayout: UICollectionViewLayout,
							   sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
		let widthPerItem = 85 + paddingSpace / itemsPerRow
		
		return CGSize(width: widthPerItem, height: 120)
	}
	
	
	public func collectionView(_ collectionView: UICollectionView,
							   layout collectionViewLayout: UICollectionViewLayout,
							   insetForSectionAt section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	
	public func collectionView(_ collectionView: UICollectionView,
							   layout collectionViewLayout: UICollectionViewLayout,
							   minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return sectionInsets.left
	}
}

extension HomeViewController {
	static func favouritesStationCollectionViewDataSource() -> CollectionViewSectionedDataSource<HomeStationsSection>.ConfigureCell {
		return { dataSource, cv, idxPath, item in
			let cell = cv.dequeueReusableCell(withReuseIdentifier: "FavouritesStationsCell", for: idxPath) as! FavouritesStationsCell

			cell.configure(with: item)

			return cell
		}
	}
}

// MARK: Data

struct HomeStationsSection {
	var header: String
	
	var stations: [Station]
	
	var updated: Date
	
	init(header: String, numbers: [Item], updated: Date) {
		self.header = header
		self.stations = numbers
		self.updated = updated
	}
}

// MARK: Just extensions to say how to determine identity and how to determine is entity updated

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
