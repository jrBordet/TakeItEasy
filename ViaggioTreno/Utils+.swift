//
//  Utils+.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import Foundation


func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
	guard
		let a = a,
		let b = b else {
		return nil
	}
	
	return (a, b)
}

func trainSectionStatus() -> (Int?) -> String {
	return { status in
		guard let status = status, status != 0 else {
			return ""
		}
		
		return String("\(status)'")
	}
}
