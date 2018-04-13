import MapKit

class VenueAnnotation: NSObject, MKAnnotation {

    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let image: UIImage?

    init(title: String,
         subtitle: String?,
         coordinate: CLLocationCoordinate2D,
         image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = image
    }
}
