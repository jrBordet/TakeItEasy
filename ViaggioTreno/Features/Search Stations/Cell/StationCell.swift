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
			
    override func awakeFromNib() {
        super.awakeFromNib()
		
		stationNameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 17)
    }
	
	func configure(_ favourite: Bool) {
		if favourite {
			stationNameLabel
				|> theme.primaryLabel
				<> fontMedium(with: 17)
		} else {
			stationNameLabel
				|> theme.primaryLabel
				<> fontRegular(with: 17)
		}
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
