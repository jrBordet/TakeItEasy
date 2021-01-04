//
//  Trend+FileClient.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 03/01/21.
//

import Foundation
import Networking
import FileClient

struct TrendFileClient: FileClient {
	typealias model = [Trend]

	var fileName: String = "following_trend"
}
