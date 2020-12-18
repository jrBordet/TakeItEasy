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

public class HomeViewController: BaseViewController {
	@IBOutlet var open: UIButton!
	
	private let disposeBag = DisposeBag()
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		open.rx.tap
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
