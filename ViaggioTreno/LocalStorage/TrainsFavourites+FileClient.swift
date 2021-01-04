//
//  TrainsFavourites+FileClient.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 04/01/21.
//

import Foundation
import FileClient

struct TrainsFavouritesFileClient: FileClient {
	typealias model = [FollowingTrain]

	var fileName: String = "favourites_trains"
}
