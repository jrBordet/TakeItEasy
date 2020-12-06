@_exported import Foundation

public enum Result<A> {
    case success(A)
    case failure(Error)
}

public typealias ResultCompletion<Value> = (Result<Value>) -> Void
