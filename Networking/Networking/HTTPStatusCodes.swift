import Foundation

extension HTTPStatusCodes {
    public static func decode(from response: URLResponse?) -> HTTPStatusCodes? {
        guard let HTTPURLResponse = (response as? HTTPURLResponse),
            let statusCode = HTTPStatusCodes(rawValue: HTTPURLResponse.statusCode) else {
                return nil
        }
        
        return statusCode
    }
}
