import Foundation

internal class RequestProvider<T: RequestTarget> {

    internal enum RequestProviderError: Error {
        case invalidData
        case invalidOutput
    }

    fileprivate let session: URLSession

    public init() {
        session = URLSession.shared
    }

    @discardableResult
    internal func responseData(target: T, completion: @escaping (Data?, Error?) -> Void) -> URLSessionTask? {
        
        guard let request = target.urlRequest else {
            return nil
        }
        
        print(request)

        let task = session.dataTask(with: request) { [weak self] data, _, error in
            if self == nil {
                return
            }

            DispatchQueue.main.async {
                completion(data, error)
            }
        }

        task.resume()
        return task
    }

    @discardableResult
    internal func response<Object: Decodable>(target: T,
                                              jsonDecoder: JSONDecoder = JSONDecoder(),
                                              completion: @escaping (Object?, Error?) -> Void) -> URLSessionTask? {
        return responseData(target: target) { data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, RequestProviderError.invalidData)
                return
            }

            do {
                let object = try jsonDecoder.decode(Object.self, from: data)
                completion(object, nil)
            } catch let jsonDecodingError {
                completion(nil, jsonDecodingError)
            }

        }
    }

    @discardableResult
    internal func responseJSON(target: T,
                               completion: @escaping (Any?, Error?) -> Void) -> URLSessionTask? {
        return responseData(target: target) { data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, RequestProviderError.invalidData)
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data,
                                                                  options: [])
                completion(jsonObject, nil)
            } catch let jsonError {
                completion(nil, jsonError)
            }
        }
    }

    @discardableResult
    internal func responseString(target: T,
                                 completion: @escaping (String?, Error?) -> Void) -> URLSessionTask? {
        return responseData(target: target) { data, error in
            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, RequestProviderError.invalidData)
                return
            }

            guard let outputString = String(data: data, encoding: .utf8) else {
                completion(nil, RequestProviderError.invalidOutput)
                return
            }

            completion(outputString, nil)
        }
    }
}
