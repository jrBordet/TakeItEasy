//
//  BaseViewController.swift
//  Features
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import UIKit

public class BaseViewController: UIViewController {
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	// MARK: - Init
	
	public init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}

extension UIViewController {
	public func registerTableViewCell(with tableView: UITableView, cell: UITableViewCell.Type, reuseIdentifier: String) {
		tableView.register(
			cell.self,
			forCellReuseIdentifier: reuseIdentifier
		)
		
		tableView.register(
			UINib(
				nibName: reuseIdentifier,
				bundle: Bundle(for: type(of: self))
			),
			forCellReuseIdentifier: reuseIdentifier
		)
	}
	
	public func register(with collectionView: UICollectionView, cell: UICollectionViewCell.Type, identifier: String) {
		collectionView.register(
			cell.self,
			forCellWithReuseIdentifier: identifier
		)
		
		collectionView.register(
			UINib(
				nibName: identifier,
				bundle: Bundle(for: type(of: self))
			),
			forCellWithReuseIdentifier: identifier
		)
	}
}
