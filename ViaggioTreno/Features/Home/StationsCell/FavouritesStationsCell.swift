//
//  FavouritesStationsCell.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 18/12/2020.
//

import UIKit

class FavouritesStationsCell: UICollectionViewCell {
	@IBOutlet private var value: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configure(with value: String) {
		self.value?.text = value
	}

}
