import Foundation

struct AppKeyValueStorage: Storage {

    func store<T>(value: T, for key: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(value, forKey: key)
    }

    func value<T>(for key: String) -> T? {
        let userDefault = UserDefaults.standard
        return userDefault.value(forKey: key) as? T
    }
}
