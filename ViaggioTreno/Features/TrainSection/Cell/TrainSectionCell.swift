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
	@IBOutlet var currentContainer: UIView!
	@IBOutlet var currentView: UIView!
	@IBOutlet var delayLabel: UILabel!
	
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
			<> fontRegular(with: 19)
		
		delayLabel
			|> theme.primaryLabel
			<> fontThin(with: 19)
		
		currentView
			|> { [weak self] in $0.backgroundColor = self?.theme.primaryColor }
			<> rounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
