//
//  FavouritesStationsCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 18/12/2020.
//

import UIKit
import Styling
import Caprice
import Networking

class FavouritesStationsCell: UICollectionViewCell {
	@IBOutlet private var initialNameLabel: UILabel!
	@IBOutlet var completeNameLabel: UILabel!
	@IBOutlet var cardView: UIView!
	
	let theme: AppThemeMaterial = .theme
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configure(with value: Station) {
		self.completeNameLabel?.text = value.name.capitalized
		
		cardView
			|> theme.cardView
			<> { $0.layer.cornerRadius = $0.frame.width / 2 }
		
		initialNameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 21)
			<> textColor(color: theme.primaryColor)
		
		completeNameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 11)
		
		let stationNames = value.name.split(separator: " ")

		if let first = stationNames.first {
			if let last = stationNames.last, stationNames.count > 1 {
				self.initialNameLabel?.text = String(first.first ?? Character("")).uppercased() + String(last.first ?? Character("")).uppercased()
			} else {
				self.initialNameLabel?.text = String(first.first ?? Character("")).uppercased()
			}
		}
	}

}
