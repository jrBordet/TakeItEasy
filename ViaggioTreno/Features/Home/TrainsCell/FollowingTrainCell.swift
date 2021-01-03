//
//  FollowingTrainCell.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 03/01/21.
//

import UIKit
import Caprice
import Styling

class FollowingTrainCell: UICollectionViewCell {
	@IBOutlet var cardView: UIView!
	@IBOutlet var originLabel: UILabel!
	@IBOutlet var destinationLabel: UILabel!
	@IBOutlet var departureTimeLabel: UILabel!
	@IBOutlet var arrivalTimeLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		cardView
			|> theme.cardView
			<> { $0.layer.cornerRadius = 5  }
		
		originLabel
			|> theme.primaryLabel
			<> fontRegular(with: 18)
		
		destinationLabel
			|> theme.primaryLabel
			<> fontRegular(with: 18)
		
		departureTimeLabel
			|> theme.primaryLabel
			<> fontRegular(with: 16)
		
		arrivalTimeLabel
			|> theme.primaryLabel
			<> fontRegular(with: 16)
    }

}
