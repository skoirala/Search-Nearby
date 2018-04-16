import CoreLocation

enum LocationAuthorizationStatus {
    case authorized
    case notDetermined
    case denied
}

class LocationService: NSObject {
    let locationManager: CLLocationManager

    let storage: Storage

    let lock = NSLock()

     init(storage: Storage) {
        self.storage = storage
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        super.init()
        locationManager.delegate = self
    }

    func lastUpdatedLocation() -> CLLocationCoordinate2D {
        let locationCoordinate: CLLocationCoordinate2D

        lock.lock()
        let latitude: Double = storage.value(for: App.latitudeStorageKey) ??
                                        App.defaultLatitude
        let longitude: Double = storage.value(for: App.longitudeStorageKey) ??
                                        App.defaultLongitude

        locationCoordinate = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
        lock.unlock()

        return locationCoordinate
    }

    func authorizationStatus() -> LocationAuthorizationStatus {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .notDetermined
        }
    }

    func authorize() {
        locationManager.requestWhenInUseAuthorization()
    }

    func updateLocation() {
        let status = authorizationStatus()

        if case .notDetermined = status {
            authorize()
            return
        }

        if case .authorized = status {
            locationManager.startUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func store(coordinate: CLLocationCoordinate2D,
               at time: Date) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        lock.lock()
        storage.store(value: latitude,
                      for: App.latitudeStorageKey)
        storage.store(value: longitude,
                      for: App.longitudeStorageKey)
        storage.store(value: time,
                      for: App.locationUpdatedTimestampKey)
        lock.unlock()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if case .authorizedWhenInUse = status {
            updateLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }

        store(coordinate: location.coordinate,
              at: location.timestamp)

        stopUpdatingLocation()
    }
}
