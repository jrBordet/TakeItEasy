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

public class HomeViewController: BaseViewController {
	@IBOutlet var searchStationsButton: UIButton!
	@IBOutlet var stationsCollectionView: UICollectionView!
	@IBOutlet var addLabel: UILabel!
	@IBOutlet var plusLabel: UILabel!
	
	let theme: AppThemeMaterial = .theme
	
	private let disposeBag = DisposeBag()
	
	// MARK: - CollectionView layout
	
	private let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 0)
	
	private let itemsPerRow: CGFloat = 1
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		// MARK: - styling
		
		addLabel
			|> theme.primaryLabel
			<> fontRegular(with: 13)
			<> textColor(color: theme.primaryColor)
			<> textLabel(L10n.App.Home.addStations)

		plusLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> textColor(color: theme.primaryColor)
			<> textLabel(L10n.App.Home.plus)
		
		// MARK: - Collection view layout
		
		stationsCollectionView.delegate = self
		
		// Do any additional setup after loading the view.
		
		let configureViewCell = HomeViewController.favouritesStationCollectionViewDataSource()
		
		let dataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: configureViewCell)
		
		register(with: stationsCollectionView, cell: FavouritesStationsCell.self, identifier: "FavouritesStationsCell")
		
		Observable<[NumberSection]>
			.just([NumberSection(header: "", numbers: Station.milano + Station.milano, updated: Date())])
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
					vc.store = applicationStore.view(
						value: { $0.stations },
						action: { .stations($0) }
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
	static func favouritesStationCollectionViewDataSource() -> CollectionViewSectionedDataSource<NumberSection>.ConfigureCell {
		return { _, cv, ip, i in
			let cell = cv.dequeueReusableCell(withReuseIdentifier: "FavouritesStationsCell", for: ip) as! FavouritesStationsCell
			
			
			cell.configure(with: i)
			
			return cell
		}
	}
}

// MARK: Data

struct NumberSection {
	var header: String
	
	var numbers: [Station]
	
	var updated: Date
	
	init(header: String, numbers: [Item], updated: Date) {
		self.header = header
		self.numbers = numbers
		self.updated = updated
	}
}

struct IntItem {
	let number: Int
	let date: Date
}

// MARK: Just extensions to say how to determine identity and how to determine is entity updated

extension NumberSection: AnimatableSectionModelType {
	typealias Item = Station
	typealias Identity = String
	
	var identity: String {
		return header
	}
	
	var items: [Station] {
		return numbers
	}
	
	init(original: NumberSection, items: [Item]) {
		self = original
		self.numbers = items
	}
}

extension NumberSection: CustomDebugStringConvertible {
	var debugDescription: String {
		let interval = updated.timeIntervalSince1970
		let numbersDescription = numbers.map { "\n\($0.name)" }.joined(separator: "")
		return "NumberSection(header: \"\(self.header)\", numbers: \(numbersDescription)\n, updated: \(interval))"
	}
}

extension Station: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return id
	}
}

extension IntItem: IdentifiableType, Equatable {
	typealias Identity = Int
	
	var identity: Int {
		return number
	}
}

// equatable, this is needed to detect changes
func == (lhs: IntItem, rhs: IntItem) -> Bool {
	return lhs.number == rhs.number && lhs.date == rhs.date
}

// MARK: Some nice extensions
extension IntItem: CustomDebugStringConvertible {
	var debugDescription: String {
		return "IntItem(number: \(number), date: \(date.timeIntervalSince1970))"
	}
}

extension IntItem: CustomStringConvertible {
	var description: String {
		return "\(number)"
	}
}

extension NumberSection: Equatable {
	
}

func == (lhs: NumberSection, rhs: NumberSection) -> Bool {
	return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}
