//
//  ArrivalsDeparturesCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 21/12/2020.
//

import UIKit
import Styling
import Caprice

class ArrivalsDeparturesCell: UITableViewCell {
	@IBOutlet var cardView: UIView!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var statusLabel: UILabel!
	
	let theme: AppThemeMaterial = .theme
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		cardView
			|> theme.cardView
		
		timeLabel
			|> theme.primaryLabel
			<> fontThin(with: 19)
		
		titleLabel
			|> theme.primaryLabel
			<> fontRegular(with: 19)
		
		statusLabel
			|> theme.primaryLabel
			<> fontThin(with: 19)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
