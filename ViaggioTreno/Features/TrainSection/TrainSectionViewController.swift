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

extension Reactive where Base: Store<TrainSectionViewState, TrainSectionViewAction> {
	var sections: Binder<(String, String)> {
		Binder(self.base) { store, value in
			store.send(.section(.trainSections(value.0, value.1)))
		}
	}
	
	var refresh: Binder<(String, String)> {
		Binder(self.base) { store, value in
			store.send(.section(.refresh(value.0, value.1)))
		}
	}
}

// MARK: - Data

struct TrainSectionItem {
	var number: String
	var name: String
	var time: String
	var status: String
	var current: Bool
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
	@IBOutlet var emptyContainer: UIView!
	@IBOutlet var emptyLabel: UILabel!
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var closeContainer: UIView!
		
	typealias TrainSectionItemModel = AnimatableSectionModel<String, TrainSectionItem>
	
	var dataSource: RxTableViewSectionedAnimatedDataSource<TrainSectionItemModel>!
	
	public var store: Store<TrainSectionViewState, TrainSectionViewAction>?
	
	private let disposeBag = DisposeBag()
	
	// MARK: - Life cycle
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		guard let store = self.store else {
			return
		}
		
		store.send(.section(.selectTrain(nil)))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let store = self.store else {
			return
		}
		
		// MARK: - Styling down
		
		tableView.allowsSelection = false
		
		let refreshControl = UIRefreshControl()
		
		refreshControl.tintColor = theme.primaryColor
		
		tableView.addSubview(refreshControl)
		tableView.alwaysBounceVertical = true
		
		self.navigationController?.navigationBar.isHidden = false
		
		tableView.estimatedRowHeight = 56
		tableView.rowHeight = UITableView.automaticDimension
	
		tableView.separatorColor = .clear
		
		registerTableViewCell(with: tableView, cell: TrainSectionCell.self, reuseIdentifier: "TrainSectionCell")
		
		setupDataSource()
		
		headerView |> { $0?.backgroundColor = theme.primaryColor }
		
		closeContainer.isHidden = true
		
		refreshControl
			.rx
			.controlEvent(.valueChanged)
			.map { _ in () }
			.flatMapLatest {
				store
					.value
					.map { (originCode: $0.originCode, train: $0.train?.number) }
					.map { zip($0, $1) }
					.ignoreNil()
					.distinctUntilChanged { $0 == $1 }
					.map { (originCode: $0, train: String($1)) }
			}
			.bind(to: store.rx.refresh)
			.disposed(by: disposeBag)
		
		// MARK: - Refresh
		
		store
			.value
			.map { $0.isRefreshing }
			.distinctUntilChanged()
			.asDriver(onErrorJustReturn: false)
			.drive(refreshControl.rx.isRefreshing)
			.disposed(by: disposeBag)
		
		closeContainer |> backgroundColor(with: theme.primaryColor)
		
		closeButton
			|> {
				$0?.setTitleColor(.white, for: .normal)
				$0?.setTitle(L10n.App.Common.x, for: .normal)
			}
		
		trainStatusLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> textColor(color: .white)
		
		trainLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> textColor(color: .white)
		
		store
			.value
			.map { $0.train?.name }
			.ignoreNil()
			.map { String($0).capitalized }
			.bind(to: trainLabel.rx.text)
			.disposed(by: disposeBag)
		
		store
			.value
			.map { $0.train?.status }
			.ignoreNil()
			.bind(to: trainStatusLabel.rx.text)
			.disposed(by: disposeBag)
		
		// MARK: - Close
		
		closeButton.rx
			.tap
			.bind { [weak self] in
			self?.dismiss(animated: true, completion: nil)
		}.disposed(by: disposeBag)
		
		// MARK: - retrieve data
		
		store
			.value
			.map { (originCode: $0.originCode, train: $0.train?.number) }
			.map { zip($0, $1) }
			.ignoreNil()
			.distinctUntilChanged { $0 == $1 }
			.map { (originCode: $0, train: String($1)) }
			.bind(to: store.rx.sections)
			.disposed(by: disposeBag)
		
		// MARK: - Bind dataSource
		
		func formattedDate(with time: TimeInterval) -> String {
			let dateFormatter = DateFormatter()
			
			dateFormatter.dateStyle = .none
			dateFormatter.timeStyle = .short
						
			return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time / 1000)))
		}
		
		// MARK: - Error
		
		store
			.error
			.map { e -> Bool in
				return false

				guard ((e as? APIError) != nil) else {
					return false
				}
								
				return true
			}
			.bind(to: emptyContainer.rx.isVisible)
			.disposed(by: disposeBag)
		
		emptyLabel
			|> theme.primaryLabel
			<> fontThin(with: 23)
			<> textLabel(L10n.Sections.empty)

		// MARK: - Sections
		
		func trainSectionStatus() -> (Int?) -> String {
			return { status in
				guard let status = status, status != 0 else {
					return ""
				}
				
				return String("\(status)'")
			}
		}
		
		func map(trainSection: TrainSection) -> TrainSectionItem {
			TrainSectionItem(
				number: trainSection.stazione,
				name: trainSection.stazione,
				time: formattedDate(with: (trainSection.fermata.partenza_teorica ?? trainSection.fermata.programmata) ?? 1000),
				status: trainSection.fermata.ritardo |> trainSectionStatus(),
				current: trainSection.stazioneCorrente ?? false
			)
		}
		
		store
			.value
			.distinctUntilChanged()
			.map { $0.trainSections }
			.map { $0.map { map(trainSection: $0) } }
			.map { items -> [TrainSectionItemModel] in
				[TrainSectionItemModel(model: "", items: items)]
			}
			.asDriver(onErrorJustReturn: [])
			.drive(tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}
	
	private func setupDataSource() {
		dataSource = RxTableViewSectionedAnimatedDataSource<TrainSectionItemModel>(
			animationConfiguration: AnimationConfiguration(insertAnimation: .top,
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
			
			cell.sectionLabel.text = item.name.capitalized + item.name.capitalized
			cell.timeLabel.text = item.time
			cell.currentContainer.isHidden = item.current == false
			cell.delayLabel.text = item.status
			
			return cell
		}
	}
}

//		tableView.rx
//			.contentOffset
//			.map { $0.y }
//			.distinctUntilChanged()
//			.debug("[\(self.debugDescription)]", trimOutput: false)
//			.subscribe(onNext: { [weak self] scrollY in
//				guard let self = self else {
//					return
//				}
//
//				let maxHeight: CGFloat = 180.0
//				let minHeight: CGFloat = 64.0
//
//				let headerViewMinHeight: CGFloat = 44 + UIApplication.shared.statusBarFrame.height
//
//				let newHeaderViewHeight: CGFloat = self.headerHeightConstraint.constant - scrollY
//
//				if newHeaderViewHeight > maxHeight {
//					// Here, Manage Your Score Format View
//					self.headerHeightConstraint.constant = maxHeight
////					self.headerHeightConstraint.constant = max(maxHeight, newHeaderViewHeight)
//				} else if newHeaderViewHeight < headerViewMinHeight {
//					self.headerHeightConstraint.constant = headerViewMinHeight
//				} else {
//					self.headerHeightConstraint.constant = newHeaderViewHeight
//					//scrollY = 0 // block scroll view
//				}
//			}).disposed(by: disposeBag)
