//
//  Favourites+FileClient.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 18/12/2020.
//

import Foundation
import Networking

public struct FavouritesFileClient: FileClient {
	public typealias model = [Station]

	public var fileName: String = "favourites_stations"
	
	public init() {}
}
