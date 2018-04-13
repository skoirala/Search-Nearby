import UIKit
import MapKit

class MapViewController<T: MapViewPresenterType>: UIViewController, MKMapViewDelegate {

    let presenter: T

    let mapView = MKMapView(frame: .zero)

    init(presenter: T) {
        self.presenter = presenter
        super.init(nibName: nil,
                   bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppeared()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attach(view: self)
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        view.addSubview(mapView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            ])
    }

    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? VenueAnnotation else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Venue") as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = createAnnotationView(with: annotation)
        }
        return annotationView
    }

    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        presenter.showVenueDetail()
    }

    func createAnnotationView(with annotation: VenueAnnotation) -> MKMarkerAnnotationView {
        let annotationView = MKMarkerAnnotationView(annotation: annotation,
                                                reuseIdentifier: "Venue")
        annotationView.glyphImage = annotation.image
        annotationView.markerTintColor = .loginButtonHighlighted
        annotationView.canShowCallout = true
        annotationView.animatesWhenAdded = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
}

extension MapViewController: MapViewType {
    func set(detail: MapViewDetailData) {
        let location = CLLocationCoordinate2D(latitude: detail.latitude,
                                              longitude: detail.longitude)

        let image: UIImage?

        if let imageUrl = detail.imageUrl {
            image = ImageDownloader.default.image(for: imageUrl)
        } else {
            image = nil
        }

        let pointAnnotation = VenueAnnotation(title: detail.title,
                                              subtitle: detail.subtitle,
                                              coordinate: location,
                                              image: image)
        mapView.addAnnotation(pointAnnotation)

        let span = MKCoordinateSpan(latitudeDelta: 0.05,
                                    longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location,
                                        span: span)
        mapView.setRegion(region,
                          animated: true)
    }
}
