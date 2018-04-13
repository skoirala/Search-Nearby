import Foundation

enum RequestTargetMock: RequestTarget {
    var params: [String: String] {
        switch self {
        case .sampleTarget(_, let paramDict, _, _):
            return paramDict
        }
    }

    var path: String {
        switch self {
        case .sampleTarget(_, _, let urlPath, _):
            return urlPath
        }
    }

    var method: HttpMethod {
        switch self {
        case .sampleTarget(_, _, _, let httpMethod):
            return httpMethod
        }
    }

    case sampleTarget(baseUrl: String, params: [String: String], path: String, method: HttpMethod)

    var baseUrl: String {
        switch self {
        case .sampleTarget(let url, _, _, _):
            return url
        }
    }
}
