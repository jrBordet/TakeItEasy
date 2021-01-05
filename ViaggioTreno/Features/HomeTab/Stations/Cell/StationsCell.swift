//
//  StationsCell.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 04/01/21.
//

import UIKit
import Caprice
import Styling

class StationsCell: UITableViewCell {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var containerShortNameView: UIView!
	@IBOutlet var cardView: UIView!
	@IBOutlet var shortNameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		containerShortNameView
			|> theme.cardView
			<> { $0.layer.cornerRadius = $0.frame.width / 2 }
		
		cardView
			|> { $0.layer.cornerRadius = 5 }
		
		shortNameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 18)
			<> Styling.textColor(color: theme.primaryColor)
		
		nameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 18)
    }
	
	func configure(with value: FavouritesStationsSectionItem) {
		nameLabel.text = value.name.capitalized
		
		let stationNames = value.name.split(separator: " ")

		if let first = stationNames.first {
			if let last = stationNames.last, stationNames.count > 1 {
				self.shortNameLabel?.text = String(first.first ?? Character("")).uppercased() + String(last.first ?? Character("")).uppercased()
			} else {
				self.shortNameLabel?.text = String(first.first ?? Character("")).uppercased()
			}
		}
	}
}
