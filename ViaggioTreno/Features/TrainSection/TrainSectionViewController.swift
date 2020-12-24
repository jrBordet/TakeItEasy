//
//  TrainSectionViewController.swift
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

// MARK: - Data

struct TrainSectionItem {
	var number: String
	var name: String
	var time: String
	var status: String
}

extension TrainSectionItem: IdentifiableType {
	public typealias Identity = String
	
	public var identity: String {
		return number
	}
}

extension TrainSectionItem: Equatable { }

// MARK: - ViewController

class TrainSectionViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var trainStatusLabel: UILabel!
	@IBOutlet var trainLabel: UILabel!
	@IBOutlet var headerView: UIView!
	@IBOutlet var headerHeightConstraint: NSLayoutConstraint!
	
	let theme: AppThemeMaterial = .theme
	
	typealias TrainSectionItemModel = AnimatableSectionModel<String, TrainSectionItem>
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<TrainSectionItemModel>!
	
	public var store: Store<TrainSectionViewState, TrainSectionViewAction>?
	
	private let disposeBag = DisposeBag()
	

	
	// MARK: - Life cycle
	
	private var lastContentOffset: CGFloat = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		tableView.rx
			.contentOffset
			.map { $0.y }
			.distinctUntilChanged()
			.debug("[\(self.debugDescription)]", trimOutput: false)
			.subscribe(onNext: { [weak self] scrollY in
				guard let self = self else {
					return
				}
				
				let maxHeight: CGFloat = 210.0
				let minHeight: CGFloat = 64.0
				
				let headerViewMinHeight: CGFloat = 44 + UIApplication.shared.statusBarFrame.height

				let newHeaderViewHeight: CGFloat = self.headerHeightConstraint.constant - scrollY

				if newHeaderViewHeight > maxHeight {
					// Here, Manage Your Score Format View
					self.headerHeightConstraint.constant = maxHeight
//					self.headerHeightConstraint.constant = max(maxHeight, newHeaderViewHeight)
				} else if newHeaderViewHeight < headerViewMinHeight {
					self.headerHeightConstraint.constant = headerViewMinHeight
				} else {
					self.headerHeightConstraint.constant = newHeaderViewHeight
					//scrollY = 0 // block scroll view
				}
			}).disposed(by: disposeBag)
		
		self.navigationController?.navigationBar.isHidden = true
		
		tableView.rowHeight = 85
		tableView.separatorColor = .white
		
		registerTableViewCell(with: tableView, cell: TrainSectionCell.self, reuseIdentifier: "TrainSectionCell")
		
		setupDataSource()
		
		headerView |> { $0?.backgroundColor = theme.primaryColor }
		
		trainStatusLabel
			|> theme.primaryLabel
			<> fontRegular(with: 19)
			<> textColor(color: .white)
		
		trainLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> textColor(color: .white)
		
		// MARK: - retrieve data
		
		//store.send(TrainSectionViewAction.section(TrainSectionAction.trainSections("", "")))
		
		// MARK: - Bind dataSource
		
		func formattedDate(with time: TimeInterval) -> String {
			let dateFormatter = DateFormatter()
			
			dateFormatter.dateStyle = .none
			dateFormatter.timeStyle = .short
			
			//dateFormatter.locale = Locale(identifier: "it_IT")
			
			return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time / 1000)))
		}
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.trainSections }
			.map {
				$0.map {
					TrainSectionItem(number: $0.stazione, name: $0.stazione, time: formattedDate(with: $0.fermata.partenzaReale ?? 1000), status: "status")
				}
			}.map { (items: [TrainSectionItem]) -> [TrainSectionItemModel] in
				[TrainSectionItemModel(model: "", items: items)]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<TrainSectionItemModel>(
			animationConfiguration: AnimationConfiguration(insertAnimation: .right,
														   reloadAnimation: .none),
			configureCell: configureCell
		)
	}
}

// MARK: - Data Source Configuration

extension TrainSectionViewController {
	private var configureCell: RxTableViewSectionedAnimatedDataSource<TrainSectionItemModel>.ConfigureCell {
		return { _, table, idxPath, item in
			guard let cell = table.dequeueReusableCell(withIdentifier: "TrainSectionCell", for: idxPath) as? TrainSectionCell else {
				return UITableViewCell(style: .default, reuseIdentifier: nil)
			}
			
			cell.sectionLabel.text = item.name.capitalized
			cell.timeLabel.text = item.time
			
			return cell
		}
	}
}
