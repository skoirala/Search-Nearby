import Foundation

extension RequestTarget {

    internal var urlRequest: URLRequest? {
        guard let url = requestUrl else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpBody = httpBody
        return request
    }

    internal var requestUrl: URL? {

        guard let relativeUrl = URL(string: baseUrl) else {
            return nil
        }

        var components = URLComponents()
        components.path = path

        let queryItems = getQueryItems()

        if .get == method && !queryItems.isEmpty {
            components.queryItems = getQueryItems()
        }

        return components.url(relativeTo: relativeUrl)
    }

    internal var httpBody: Data? {
        guard .get != method else {
            return nil
        }

        var components = URLComponents()
        components.queryItems = getQueryItems()

        guard let queryPath = components.query else {
            return nil
        }

        return queryPath.data(using: .utf8)
    }

    private func getQueryItems() -> [URLQueryItem] {
        return params.reduce([]) { items, queryKeyValue in
            return items + [URLQueryItem(name: queryKeyValue.key,
                                         value: queryKeyValue.value)]
        }
    }
}
