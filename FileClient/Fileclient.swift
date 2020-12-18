//
//  Fileclient.swift
//  Countries
//
//  Created by Jean Raphael Bordet on 22/06/2020.
//  Copyright © 2020 Bordet. All rights reserved.
//

import Foundation

public protocol FileClient {
	associatedtype model: Codable
	
	var fileName: String { get }
}

public enum PersistenceError: Error, Equatable {
	case emptyFileName
	case generic(String)
}

extension FileClient {
	public func persist(_ model: model) -> Result<Bool, PersistenceError> {
		guard fileName.isEmpty == false else {
			return .failure(PersistenceError.generic("fileName is empty"))
		}
		
		do {
			let data = try JSONEncoder().encode(model)
			
			guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
				return .failure(.generic("Unable to find documentDirectory"))
				
			}
			
			let documentsUrl = URL(fileURLWithPath: documentsPath)
			let url = documentsUrl.appendingPathComponent(fileName)
			
			try data.write(to: url)
			
			return .success(true)
		} catch let e {
			return .failure(.generic(e.localizedDescription))
		}
	}
	
	public func retrieve() -> Result<model, PersistenceError> {
		guard let data = loadData(from: fileName) else {
			return .failure(.generic("unbale to load data from empty fileName"))
		}
		
		do {
			let value = try JSONDecoder().decode(model.self, from: data)
			
			return .success(value)
		} catch let e {
			return .failure(.generic(e.localizedDescription))
		}
	}
}

private func loadData(from fileName: String, directory: FileManager.SearchPathDirectory = .documentDirectory) -> Data? {
	do {
		return try NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
			.first
			.map { URL(fileURLWithPath: $0).appendingPathComponent(fileName) }
			.map { try Data(contentsOf: $0) }
	} catch {
		return nil
	}
}
