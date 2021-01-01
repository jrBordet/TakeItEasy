//
//  Difference+.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 11/12/2020.
//

import Foundation
import XCTest
import Difference

public func XCTAssertEqual<T: Equatable>(_ expected: T, _ received: T, file: StaticString = #file, line: UInt = #line) {
	XCTAssertTrue(expected == received, "Found difference for \n" + diff(expected, received).joined(separator: ", "), file: file, line: line)
}
