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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		// MARK: - Create bar
		
		let bar = TMBar.TabBar()
		bar.layout.transitionStyle = .snap
		
		let systemBar = bar.systemBar()
		systemBar.backgroundStyle = .blur(style: .dark)
		
		bar.layout.contentInset = UIEdgeInsets(top: -30.0, left: 20.0, bottom: 10.0, right: 20.0)
		
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
			return TMBarItem(title: L10n.App.Common.arrivals)
		case .trains:
			return TMBarItem(title: L10n.App.Common.departures)
		}
	}
}

enum HomeTab: Int {
	case stations, trains
}
