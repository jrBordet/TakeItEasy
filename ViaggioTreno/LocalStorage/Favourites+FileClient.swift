//
//  Favourites+FileClient.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 18/12/2020.
//

import Foundation
import Networking
import FileClient

struct FavouritesFileClient: FileClient {
	typealias model = [Station]

	var fileName: String = "favourites_stations"
}
