import Foundation

protocol RequestTarget {
    var baseUrl: String { get }
    var params: [String: String] { get }
    var path: String { get }
    var method: HttpMethod { get }
}
