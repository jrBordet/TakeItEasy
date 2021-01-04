//
//  HomeTabViewController.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 04/01/21.
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

class HomeTabViewController: TabmanViewController {
	
	public var viewControllers: [UIViewController] = [
		FavouritesStationsViewController(),
		DeparturesViewController()
	]
	
	var store: Store<HomeViewState, HomeViewAction>?

    override func viewDidLoad() {
        super.viewDidLoad()

		guard let store = self.store else {
			return
		}
		
		// MARK: - Stations
	
		
		if let stations = viewControllers.first as? FavouritesStationsViewController {
			stations.store = store.view {
				$0.favouritesStationsState
			} action: {
				.favourites($0)
			}
		}

		// MARK: - Create bar
		
		let bar = TMBar.TabBar()
		bar.layout.transitionStyle = .snap
		
		let systemBar = bar.systemBar()
		systemBar.backgroundStyle = .blur(style: .dark)
		
		bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 10.0, right: 20.0)
		
		bar.buttons.customize { button in
			button.tintColor = theme.primaryColor.withAlphaComponent(0.35)
			button.selectedTintColor = theme.primaryColor
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

extension HomeTabViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
		guard let tab = HomeTab(rawValue: index) else {
			return TMBarItem(title: "")
		}
		
		switch tab {
		case .stations:
			return TMBarItem(title: L10n.Stations.title)
		case .trains:
			return TMBarItem(title: L10n.App.Common.departures)
		}
	}
}

enum HomeTab: Int {
	case stations, trains
}
