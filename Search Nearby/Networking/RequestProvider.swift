import Foundation

let errorCodeTranslator = [
    400: "The request could not be understood by the server due to malformed syntax", // Bad request
    401: "The request requires user authentication", // unauthorized
    402: "Payment Required", // reserved for future use.
    403: "Resource is forbidden", // Forbidden
    404: "The server has not found anything matching the Request-URI", // Not found
    405: "Method Not Allowed"
]

internal enum RequestProviderError: Error {
    case invalidData
    case invalidOutput
    case invalidResponseReceived
    case otherError(String)
    case unknownError
}

extension RequestProviderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data received"
        case .invalidResponseReceived:
            return "Response was invalid"
        case .otherError(let errorMessage):
            return errorMessage
        case .invalidOutput:
            return "Unexpected output received"
        case .unknownError:
            return "Unknown error occurred"
        }
    }
}

internal class RequestProvider<T: RequestTarget> {

    fileprivate let session: URLSession

    public init() {
        session = URLSession.shared
    }

    func executeInMainQueue(executionBlock: @escaping () -> Void) {
        DispatchQueue.main.async {
            executionBlock()
        }
    }

    @discardableResult
    internal func responseData(target: T, completion: @escaping (Data?, Error?) -> Void) -> URLSessionTask? {
        
        guard let request = target.urlRequest else {
            return nil
        }
        
        print(request)

        let task = session.dataTask(with: request) { [weak self] data, httpResponse, error in
            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                completion(nil, error)
                return
            }

            guard let httpResponse = httpResponse as? HTTPURLResponse else {
                strongSelf.executeInMainQueue {
                    completion(nil, RequestProviderError.invalidResponseReceived)
                }
                return
            }

            guard  200..<300 ~=  httpResponse.statusCode  else {
                guard let errorMessage = errorCodeTranslator[httpResponse.statusCode] else {
                    strongSelf.executeInMainQueue {
                        completion(nil, RequestProviderError.otherError("Unknown error occurrred"))
                    }
                    return
                }

                strongSelf.executeInMainQueue {
                    completion(nil, RequestProviderError.otherError(errorMessage))
                }
                return
            }

            strongSelf.executeInMainQueue {
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
