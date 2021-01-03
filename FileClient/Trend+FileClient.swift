//
//  Trend+FileClient.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 03/01/21.
//

import Foundation
import Networking

public struct TrendFileClient: FileClient {
	public typealias model = [Trend]

	public var fileName: String = "following_trend"
	
	public init() {}
}
