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
	@IBOutlet var cardView: UIView!
	@IBOutlet var shortNameLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		cardView
			|> theme.cardView
			<> { $0.layer.cornerRadius = 5  }
		
		nameLabel
			|> theme.primaryLabel
			<> fontRegular(with: 18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
