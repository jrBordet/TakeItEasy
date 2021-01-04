//
//  StationsSectionHeader.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 16/12/2020.
//

import UIKit
import Styling
import Caprice

class StationsSectionHeader: UITableViewHeaderFooterView {
	@IBOutlet var sectionLabel: UILabel! {
		didSet {
			sectionLabel
				|> theme.primaryLabel
				<> fontRegular(with: 17)
				<> textColor(color: .white)
		}
	}
	
	@IBOutlet var containerView: UIView! {
		didSet {
			self.containerView.backgroundColor = theme.selectionColor
		}
	}
	
	let theme: AppThemeMaterial = .theme
}
