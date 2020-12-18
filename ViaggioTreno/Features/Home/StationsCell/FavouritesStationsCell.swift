//
//  FavouritesStationsCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 18/12/2020.
//

import UIKit
import Networking

class FavouritesStationsCell: UICollectionViewCell {
	@IBOutlet private var initialNameLabel: UILabel?
	@IBOutlet var completeNameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configure(with value: Station) {
		self.completeNameLabel?.text = value.name.capitalized
		
		let s = value.name.split(separator: " ")
//		s.map { (s: Substring) -> String in
//			String(s.first ?? Character(""))
//		}.flatMap { $0 }		

		if let f = s.first {
			dump("[TEST] \(f.first)")
			dump("[TEST] \(f)")
			self.initialNameLabel?.text = String(f.first ?? Character("")).uppercased()
		}
		
//		print("[TEST] \(s)")
	}

}
