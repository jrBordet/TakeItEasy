//
//  StationCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import UIKit
import Styling
import Caprice

class StationCell: UITableViewCell {
	@IBOutlet var cardView: UIView!
	@IBOutlet var stationNameLabel: UILabel!
	
	let theme: AppThemeMaterial = .theme
	
	// 20FC8F
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		cardView
			|> theme.cardView
		
		stationNameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
			<> { [weak self] in $0.textColor = self?.theme.primaryColor }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
