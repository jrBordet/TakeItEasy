//
//  ArrivalsDeparturesContainerViewController.swift
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
import Tabman
import Pageboy
import SceneBuilder

class ArrivalsDeparturesContainerViewController: TabmanViewController {
	@IBOutlet var emptyContainer: UIView!
	@IBOutlet var emptyLabel: UILabel!
	
	public var viewControllers: [UIViewController] = []
	
	let theme: AppThemeMaterial = .theme
	
	public var store: Store<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction>?
	
	private let disposeBag = DisposeBag()
	
	// MARK: - Life cycle
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		guard let store = self.store else {
			return
		}
		
		store.send(.arrivalDepartures(.select(nil)))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		self.navigationController?.navigationBar.isHidden = false
		self.navigationController?.navigationBar.tintColor = theme.primaryColor
		
		store
			.value
			.map { $0.selectedStation?.name }
			.ignoreNil()
			.map { $0.capitalized }
			.bind(to: self.rx.title)
			.disposed(by: disposeBag)

		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.primaryColor]
		
		// MARK: - Departures
		
		let departures = DeparturesViewController()
		
		departures.store = store
		
		viewControllers.append(departures)
		
		store
			.value
			.map { $0.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.bind(to: store.rx.departures)
			.disposed(by: disposeBag)
		
		// MARK: - Arrivals
		
		let arrivals = ArrivalsViewController()
		
		arrivals.store = store
		
		viewControllers.append(arrivals)
		
		store
			.value
			.map { $0.selectedStation }
			.distinctUntilChanged()
			.ignoreNil()
			.bind(to: store.rx.arrivals)
			.disposed(by: disposeBag)
		
		// MARK: - Error
		
		store
			.error
			.distinctUntilChanged({ (e1: Error?, e2: Error?) -> Bool in
				let errors = zip(e1, e2)
				
				guard let e1 = errors?.0 as? APIError, let e2 = errors?.1 as? APIError else {
					return false
				}
				
				guard e1 == e2 else {
					return false
				}
				
				return true
			})
			.map { e -> Bool in
				return false
				
				// TODO: handle error
				
				guard ((e as? APIError) != nil) else {
					return false
				}
				
				store.send(.arrivalDepartures(.arrivalsResponse([])))
				store.send(.arrivalDepartures(.departuresResponse([])))
				
				return true
			}
			.bind(to: emptyContainer.rx.isVisible)
			.disposed(by: disposeBag)
		
		emptyLabel
			|> theme.primaryLabel
			<> fontThin(with: 23)
			<> textLabel(L10n.Sections.empty)
		
		// MARK: - Train selected
		
		store
			.value
			.map { $0.train?.number }
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { [weak self] _ in
				guard let self = self else {
					return
				}
				
				navigationLink(from: self, destination: Scene<TrainSectionViewController>(), completion: { vc in
					vc.store = store.view(
						value: { $0.trainSectionsState },
						action: { .sections($0) }
					)
				}, isModal: false)
			}).disposed(by: disposeBag)

		// MARK: - Create bar
		
		let bar = TMBar.TabBar()
		bar.layout.transitionStyle = .snap
		
		let systemBar = bar.systemBar()
		systemBar.backgroundStyle = .blur(style: .dark)
		
		bar.layout.contentInset = UIEdgeInsets(top: -30.0, left: 20.0, bottom: 10.0, right: 20.0)
		
		bar.buttons.customize { [weak self] button in
			button.tintColor = self?.theme.primaryColor.withAlphaComponent(0.35)
			button.selectedTintColor = self?.theme.primaryColor
			button.font = UIFont.boldSystemFont(ofSize: 17)
			button.backgroundColor = .clear
		}
		
		reloadData()
		
		// Add to view
		addBar(bar, dataSource: self, at: .top)
		
		self.dataSource = self
	}
}

// MARK: - PageboyViewControllerDataSource, TMBarDataSource

extension ArrivalsDeparturesContainerViewController: PageboyViewControllerDataSource, TMBarDataSource {
	func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
		return viewControllers.count
	}
	
	func viewController(for pageboyViewController: PageboyViewController,
						at index: PageboyViewController.PageIndex) -> UIViewController? {
		return viewControllers[index]
	}
	
	func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
		return nil
	}
	
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		if index == 1 {
			return TMBarItem(title: L10n.App.Common.arrivals)
		} else if index == 0 {
			return TMBarItem(title: L10n.App.Common.departures)
		} else {
			return TMBarItem(title: "")
		}
	}
}
