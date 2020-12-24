//
//  TrainSectionCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 23/12/2020.
//

import UIKit
import Styling
import Caprice

class TrainSectionCell: UITableViewCell {
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var sectionLabel: UILabel!
	@IBOutlet var cardView: UIView!
	
	let theme: AppThemeMaterial = .theme
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		cardView
			|> theme.cardView
		
		timeLabel
			|> theme.primaryLabel
			<> fontThin(with: 19)
		
		sectionLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
