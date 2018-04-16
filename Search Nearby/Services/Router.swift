import Foundation
import UIKit
import MapKit

class Router {

    private weak var window: UIWindow!
    private let authenticationManager: OauthAuthenticationManager
    private weak var rootViewController: UINavigationController!
    private let storage: Storage

    init(window: UIWindow,
         storage: Storage) {
        self.window = window
        self.storage = storage
        self.authenticationManager = OauthAuthenticationManager(storage: storage,
                                                                loginService: OauthLoginService())
    }

    func start() {
        let viewControllerToPresent: UIViewController
        
        if !authenticationManager.isLoggedIn() {
            let loginViewPresenter = LoginViewPresenter(router: self,
                                                        storage: storage,
                                                        authenticationManager: authenticationManager)
            viewControllerToPresent = LoginViewController(presenter: loginViewPresenter)

        } else {
            let presenter = SearchVenuePresenter(router: self,
                                                 storage: storage)
            viewControllerToPresent = SearchVenueViewController(presenter: presenter)
        }

        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        window.rootViewController = navigationController

        self.rootViewController = navigationController
    }

    func showSearchViewController() {
        let presenter = SearchVenuePresenter(router: self,
                                             storage: storage)
        let viewController = SearchVenueViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)

        rootViewController.present(navigationController,
                                   animated: true,
                                   completion: nil)
        rootViewController = navigationController
    }

    func handleOpen(url: URL, options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return authenticationManager.handleAuthentication(url: url)
    }

    func showVenuePhotos(venue: Venue) {
        let photoPresenter = VenuePhotoPresenter(router: self,
                                                 storage: storage,
                                                 venue: venue)
        let photoViewController = VenuePhotoViewController(presenter: photoPresenter)
        rootViewController.pushViewController(photoViewController,
                                              animated: true)
   }

    func showPhotoViewer(photo: VenuePhoto) {
        let photoPresenter = PhotoViewerPresenter(photo: photo)
        let viewController = PhotoViewerViewController(presenter: photoPresenter)
        rootViewController.pushViewController(viewController,
                                              animated: true)
    }
    func showMapView(venue: Venue) {
        let mapViewPresenter = MapViewPresenter(router: self,
                                                venue: venue)
        let mapViewController = MapViewController(presenter: mapViewPresenter)
        rootViewController.pushViewController(mapViewController,
                                              animated: true)
    }

    func showDetailView(venue: Venue) {
        let presenter = VenuDetailPresenter(router: self,
                                            venue: venue)
        let venueDetailviewController = VenueDetailViewController(presenter: presenter)
        rootViewController.pushViewController(venueDetailviewController,
                                              animated: true)
    }

    func showInMaps(venue: Venue) {
        let coordinate = CLLocationCoordinate2D(latitude: venue.address.latitude,
                                                longitude: venue.address.longitude)

        let span = MKCoordinateSpan(latitudeDelta: 0.001,
                                    longitudeDelta: 0.001)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = venue.name
        let launchOptions = [MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: span),
                             MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate)]
        mapItem.openInMaps(launchOptions: launchOptions)
    }

    func showDirections(venue: Venue) {
        let coordinate = CLLocationCoordinate2D(latitude: venue.address.latitude,
                                                longitude: venue.address.longitude)

        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = venue.name
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}
