import MapKit

class MapSnapShotLoader {

    var snapShotter: MKMapSnapshotter?

    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    func generateSnapshot(of size: CGSize,
                          completion: @escaping (UIImage?, Error?) -> Void) {

        let coordinate = CLLocationCoordinate2D(latitude: latitude,
                                                longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.001,
                                    longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: coordinate,
                                        span: span)

        let snapshotOptions = MKMapSnapshotOptions()
        snapshotOptions.region = region
        snapshotOptions.mapType = .standard
        snapshotOptions.showsPointsOfInterest = true
        snapshotOptions.showsBuildings = true
        snapshotOptions.size = size

        let snapShotter = MKMapSnapshotter(options: snapshotOptions)
        snapShotter.start { [weak self] snapshot, error in
            if self != nil {
                completion(snapshot?.image, error)
            }
        }
    }

    deinit {
        snapShotter?.cancel()
    }
}
