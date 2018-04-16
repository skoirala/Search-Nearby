import XCTest
import Mockingjay

class SearchVenueViewMock: SearchVenueViewType {

    var searchResultChangeCalled = false

    func searchResultChanged() {
        searchResultChangeCalled  = true
    }
    func imageDownloadFinished(image: UIImage, for url: String) { }
}

class SearchVenuePresenterTest: XCTestCase {

    var presenter: SearchVenuePresenter!
    var router: Router!
    var storage: MockedStorage!

    override func setUp() {
        let window = UIWindow()
        storage = MockedStorage()
        try! storage.store(credential: OauthCredential(accessToken: "12345"))
        router = Router(window: window,
                        storage: storage)
        router.start()
        presenter = SearchVenuePresenter(router: router,
                                         storage: storage)
    }

    override func tearDown() {
        UserDefaults.resetStandardUserDefaults()
        storage = nil
        router = nil
        presenter = nil
    }

    func testPresenterCallbackInitiallyWithEmptyResults() {
        let view = SearchVenueViewMock()
        presenter.attach(view: view)

        XCTAssertTrue(view.searchResultChangeCalled, "Initially not called")
        XCTAssertEqual(presenter.numberOfItems(), 0, "Initially 0 items are there")
        view.searchResultChangeCalled = false
    }

    func testPresenterCallsbackWithChangeResult() {
        let searchResponse = [
            "meta": ["code": 200],
            "response": ["venues": [["id": "123123",
                                     "name": "Jumbo",
                                     "location": ["address": "Tasetie",
                                                  "city": "Vantaa",
                                                  "street": "",
                                                  "country": "",
                                                  "distance": 12.0,
                                                  "lat": 64.21,
                                                  "lng": 93.21,
                                                  "postalCode": "01520",
                                                  "state": "UUsima"],
                                     "categories": [["name": "Shopping",
                                                     "id": "123123",
                                                     "icon": ["prefix": "https://random",
                                                              "suffix": "image.png"]]]]]
            ]
        ]

        stub(everything, json(searchResponse))

        let expect = expectation(description: "Search result change call")

        let view = SearchVenueViewMock()
        presenter.attach(view: view)
        presenter.search(for: "a")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 2.0)

        XCTAssertTrue(view.searchResultChangeCalled, "Search result not changed")
        XCTAssertEqual(presenter.numberOfItems(), 1, "Must have 1 item")

        let displayResult = presenter.item(at: 0)
        XCTAssertEqual(displayResult.name, "Jumbo")
        XCTAssertEqual(displayResult.categoryName, "Shopping")
        XCTAssertEqual(displayResult.address, "Tasetie, Vantaa 01520")
    }

    func testCancelsURLTaskIfNewSearchTextIsChanged() {
        let view = SearchVenueViewMock()
        presenter.attach(view: view)
        presenter.search(for: "a")

        guard let previousTask = presenter.pendingTask else {
            XCTFail("No task created for searching")
            return
        }
        XCTAssertEqual(previousTask.state, .running)

        presenter.search(for: "ab")
        guard let newTask = presenter.pendingTask else {
            XCTFail("Previous task and next task does not exit")
            return
        }

        XCTAssertEqual(previousTask.state, .canceling)
        XCTAssertEqual(newTask.state, .running)
        XCTAssertNotEqual(previousTask, newTask)
    }
}
