import XCTest
import Mockingjay

class VenuePhotoPresenterTest: XCTestCase {

    class MockVenuePhotoView: VenuePhotoViewType {
        enum TransitionState: Equatable {
            static func == (lhs: TransitionState,
                            rhs: TransitionState) -> Bool {
                switch(lhs, rhs) {
                case (.loading, .loading): return true
                case (.loaded, .loaded): return true
                case (.empty, .empty): return true
                case (.error, .error): return true
                default:
                    return false
                }
            }

            case loading, loaded, error, empty
        }

        var states: [TransitionState] = []

        func venuePhotosLoadingStarted() {
            states.append(.loading)
        }

        func venuePhotosLoaded() {
            states.append(.loaded)
        }

        func venuePhotoLoading(failed error: Error) {
            states.append(.error)
        }

        func venuePhotoLoadingReturnedEmpty() {
            states.append(.empty)
        }

        func image(_ image: UIImage, downloadedAt index: Int) {
        }
    }

    var presenter: VenuePhotoPresenter!
    var view: MockVenuePhotoView!
    var storage: Storage!

    override func setUp() {
        view = MockVenuePhotoView()
        storage = MockedStorage()
        try! storage.store(credential: OauthCredential(accessToken: "12345"))
        let router = Router(window: UIWindow(),
                            storage: storage)
        let venue = Venue(identifier: "12342",
                                name: "Random",
                                address: Address(street: "Tammistonkatu",
                                                 city: "Vantaa",
                                                 country: "Finland",
                                                 distance: 10.0,
                                                 latitude: 12.0,
                                                 longitude: 23.0,
                                                 postalCode: "01520",
                                                 state: nil),
                                categories: [])
        presenter = VenuePhotoPresenter(router: router,
                                        storage: storage,
                                        venue: venue)
    }

    override func tearDown() {
        presenter = nil
        view = nil
    }

    func testStartsLoadingSoonAfterViewIsAttached() {
        presenter.attach(view: view)
        XCTAssertEqual(view.states, [.loading])
    }

    func testFailRequestNotifiesView() {
        let error = NSError(domain: "com.testDomain",
                            code: 101,
                            userInfo: [NSLocalizedDescriptionKey: "Could not load"])
        stub(everything, failure(error))
        presenter.attach(view: view)

        let expect = expectation(description: "Failure expectation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.5)

        XCTAssertEqual(view.states, [.loading, .error])
    }
    
    func testEmptyPhotoSuccessIsNotifiedToView() {
        let photoResponse = [
            "meta": ["code": 200],
            "response": ["photos": [
                "count": 0,
                "items": []
                ]]
        ]
        stub(everything, json(photoResponse))
        presenter.attach(view: view)

        let expect = expectation(description: "Empty photos")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.5)
        XCTAssertEqual(view.states, [.loading, .empty])
        XCTAssertEqual(presenter.numberOfVenuePhotos(), 0)
    }

    func testLoadedPhotosSuccessIsNotifiedToView() {
        let photoResponse = [
            "meta": ["code": 200],
            "response": ["photos": [
                "count": 1,
                "items": [[
                    "createdAt": 87392,
                    "height": 114,
                    "width": 432,
                    "id": "jh21kjh123",
                    "prefix": "https://somethn.com",
                    "suffix": "image.jpg"
                    ],
                          [
                            "createdAt": 87294,
                            "height": 214,
                            "width": 342,
                            "id": "jh21kjh123",
                            "prefix": "https://sometasn.com",
                            "suffix": "image1.jpg"
                    ]]
                ]]
        ]
        stub(everything, json(photoResponse))
        presenter.attach(view: view)

        let expect = expectation(description: "Photos loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.5)
        XCTAssertEqual(view.states, [.loading, .loaded])
        XCTAssertEqual(presenter.numberOfVenuePhotos(), 2)
        let photo1Size = presenter.sizeForVenuePhoto(at: 0)
        let photo2Size = presenter.sizeForVenuePhoto(at: 1)

        XCTAssertEqual(CGSize(width: 432, height: 114),
                       photo1Size)
        XCTAssertEqual(CGSize(width: 342, height: 214),
                       photo2Size)
    }
}
