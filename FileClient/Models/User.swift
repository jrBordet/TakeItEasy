//
//  User.swift
//  FileClient
//
//  Created by Jean Raphael Bordet on 23/06/2020.
//

import Foundation

public struct UserFileClient: FileClient {
    public var fileName: String = ""
    
    public typealias model = [User]
}

extension UserFileClient {
    public static var test = UserFileClient(fileName: "TEST_USER")
    
    public static var live = UserFileClient(fileName: "LIVE_USER")
    
    public static var failure = UserFileClient(fileName: "")
}

public struct User: Codable, Equatable {
    public var name: String
    public var age: Int

    public init (
        name: String,
        age: Int
    ) {
        self.name = name
        self.age = age
    }
}

extension User {
    public static var collection: [User] = [
        User(name: "AAA", age: 14),
        User(name: "BBB", age: 17),
        User(name: "CCC", age: 29)
    ]
}
