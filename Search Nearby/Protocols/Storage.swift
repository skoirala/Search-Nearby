import Foundation

enum StorageError: Error {
    case invalidData
}

protocol Storage {

    func store<T>(value: T, for key: String)

    func value<T>(for key: String) -> T?
}

extension Storage {
    
    func store(credential: OauthCredential) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase

            let json = try jsonEncoder.encode(credential)
            store(value: json,
                          for: App.credentialStorageKey)
    }

    func credential() throws -> OauthCredential {
        let data: Data? = value(for: App.credentialStorageKey)
        guard let jsonData = data else {
            throw StorageError.invalidData
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(OauthCredential.self,
                                  from: jsonData)
    }
}
