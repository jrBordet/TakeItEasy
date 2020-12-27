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
	public var viewControllers: [UIViewController] = []
	
	let theme: AppThemeMaterial = .theme
	
	public var store: Store<ArrivalsDeparturesViewState, ArrivalsDeparturesViewAction>?
	
	private let disposeBag = DisposeBag()
	
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
		self.title = L10n.App.Common.board

		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.primaryColor]
		
		// MARK: - Departures
		
		let departures = DeparturesViewController()
		
		departures.store = store
		
		viewControllers.append(departures)
		
		// MARK: - Arrivals
		
		let arrivals = ArrivalsViewController()
		
		arrivals.store = store
		
		viewControllers.append(arrivals)
		
		// MARK: - Train selected
		
		store
			.value
			.map { $0.train?.number }
			.distinctUntilChanged()
			.ignoreNil()
			.subscribe(onNext: { _ in
				navigationLink(from: self, destination: Scene<TrainSectionViewController>(), completion: { vc in
					vc.store = store.view(
						value: { $0.trainSectionsState },
						action: { .sections($0) }
					)
				}, isModal: true)
			}).disposed(by: disposeBag)

		// MARK: - Create bar
		
		let bar = TMBar.TabBar()
		bar.layout.transitionStyle = .snap
		bar.backgroundColor?.setFill()
		
		bar.layout.contentInset = UIEdgeInsets(top: -30.0, left: 20.0, bottom: 10.0, right: 20.0)
		
		bar.buttons.customize { [weak self] button in
			button.tintColor = self?.theme.primaryColor.withAlphaComponent(0.35)
			button.selectedTintColor = self?.theme.primaryColor
			button.font = UIFont.boldSystemFont(ofSize: 17)
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
