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
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		cardView
			|> { $0.layer.cornerRadius = 5 }
			<> { $0.backgroundColor = .white }
    }
	
	func configure(with origin: String) {
		originLabel.text = origin
	}
}
