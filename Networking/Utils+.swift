//
//  Utils+.swift
//  Networking
//
//  Created by Jean Raphael Bordet on 29/12/20.
//

import Foundation

extension String {
	public var trimSpaces: String {
		self.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "")
	}
	
	public var emojilessStringWithSubstitution: String {
		self.components(separatedBy: CharacterSet.symbols).joined()
	}
}
