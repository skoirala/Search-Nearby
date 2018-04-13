import Foundation

internal enum HttpMethod {
    case get, post, put, delete
}

extension HttpMethod {
    internal var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .delete:
            return "DELETE"
        case .put:
            return "PUT"
        }
    }
}
