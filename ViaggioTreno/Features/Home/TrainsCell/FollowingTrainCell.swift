//
//  FollowingTrainCell.swift
//  PendolareStanco
//
//  Created by Jean Raphael Bordet on 05/01/21.
//

import UIKit
import Caprice
import Styling

class FollowingTrainCell: UITableViewCell {
	@IBOutlet var cardView: UIView!
	
	@IBOutlet var originLabel: UILabel!
	@IBOutlet var originTimeLabel: UILabel!
	@IBOutlet var destinationLabel: UILabel!
	@IBOutlet var destinationTimeLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		cardView
			|> theme.cardView
		
		originLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
		
		destinationLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
		
		originTimeLabel
			|> theme.primaryLabel
			<> fontThin(with: 21)
		
		destinationTimeLabel
			|> theme.primaryLabel
			<> fontThin(with: 21)
    }
	
	func configure(
		with origin: String,
		originTime: String,
		destination: String,
		destinationTime: String
	) {
		originLabel.text = origin.capitalized
		originTimeLabel.text = originTime
		
		destinationLabel.text = destination.capitalized
		destinationTimeLabel.text = destinationTime
	}
}
