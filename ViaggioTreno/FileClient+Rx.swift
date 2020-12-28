//
//  FileClient+Rx.swift
//  ViaggioTreno
//
//  Created by Jean Raphael Bordet on 28/12/2020.
//

import Foundation
import RxSwift
import FileClient

extension FileClient {
	func persist(with model: Self.model) -> Observable<Bool> {
		return Observable<Bool>.create { observer in
			switch self.persist(model) {
			case let .success(value):
				observer.onNext(value)
				break
			case let .failure(e):
				observer.onError(e)
				break
			}
			
			observer.onCompleted()
			
			return Disposables.create()
		}
	}
	
	func fetch() -> Observable<Self.model> {
		return Observable<Self.model>.create { observer in
			switch self.retrieve() {
			case let .success(value):
				observer.onNext(value)
				break
			case let .failure(e):
				observer.onError(e)
				break
			}
			
			observer.onCompleted()
			
			return Disposables.create()
		}
	}
}
