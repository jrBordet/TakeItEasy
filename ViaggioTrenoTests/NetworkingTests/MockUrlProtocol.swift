//
//  MockUrlProtocol.swift
//  ViaggioTrenoTests
//
//  Created by Jean Raphael Bordet on 08/12/2020.
//

import Foundation

class MockUrlProtocol: URLProtocol {
	static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		guard let handler = MockUrlProtocol.requestHandler else {
			fatalError("no handler set")
		}
		
		do {
			let (response, data) =  try handler(request)
			
			guard let d = data else {
				fatalError("data is empty")
			}
			
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: d)
			client?.urlProtocolDidFinishLoading(self)
			
		} catch let e {
			client?.urlProtocol(self, didFailWithError: e)
		}
		
	}
	
	override func stopLoading() {
		
	}
}

func requestHandler(with data: Data?, statusCode: Int = 200) -> (URLRequest) -> (HTTPURLResponse, Data?) {
	return { request in
		let httpResponse = HTTPURLResponse(
			url: request.url!,
			statusCode: statusCode,
			httpVersion: nil,
			headerFields: nil
		)
		return (httpResponse!, data)
	}
}
