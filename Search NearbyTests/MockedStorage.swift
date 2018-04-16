//
//  MockedStorage.swift
//  Search NearbyTests
//
//  Created by Sandeep Koirala on 15/04/2018.
//  Copyright © 2018 Sandeep Koirala. All rights reserved.
//

import Foundation

class MockedStorage: Storage {

    var internalStorage: [String: Any] = [:]

    func store<T>(value: T, for key: String) {
        if let data = value as? Data,
            key == App.credentialStorageKey {
            internalStorage[App.credentialStorageKey] = data
        }
    }

    func value<T>(for key: String) -> T? {
        guard key == App.credentialStorageKey,
            let data = internalStorage[key] as? Data else {
                return nil
        }
        return data as? T
    }

}
