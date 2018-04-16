import XCTest
@testable import Search_Nearby

class LoginViewTypeMock: LoginViewType {

    var showProgressCalled: Bool = false
    var handleLoginSuccessCalled: Bool = false
    var showErrorCalled: Bool = false
    var errorString: String!

    func showProgress() {
        showProgressCalled = true
    }

    func handleLoginSuccess() {
        handleLoginSuccessCalled = true
    }

    func showError(error: String) {
        errorString = error
        showErrorCalled = true
    }
}

class UserCredentialManagerMock: OauthAuthenticationManagerType {
    var startAuthorizationCalled: Bool = false
    var observe: ((OauthCredential?, Error?) -> Void)?
    func startAuthorization() {
        startAuthorizationCalled = true
    }
}

class LoginViewPresenterTest: XCTestCase {

    var loginViewMock: LoginViewTypeMock!
    var authenticationManager: UserCredentialManagerMock!
    var loginPresenter: LoginViewPresenter!
    var storage: Storage!

    override func setUp() {
        storage = MockedStorage()
        loginViewMock = LoginViewTypeMock()
        authenticationManager = UserCredentialManagerMock()

        let window = UIWindow()
        let router = Router(window: window,
                            storage: storage)
        router.start()
        let credential = OauthCredential(accessToken: "")
        try! storage.store(credential: credential)

        loginPresenter = LoginViewPresenter(router: router,
                                            storage: storage,
                                            authenticationManager: authenticationManager)
        loginPresenter.attach(view: loginViewMock)
    }

    override func tearDown() {
        UserDefaults.resetStandardUserDefaults()
        loginViewMock = nil
        authenticationManager = nil
        loginPresenter = nil
    }

    func testShouldStartAuthorization() {
        loginPresenter.startAuthorization()

        XCTAssertTrue(loginViewMock.showProgressCalled, "show progress not called on loginView")
        XCTAssertTrue(authenticationManager.startAuthorizationCalled, "start authorization not called on credential manager")
    }

    func testViewRespondsToSuccess() {

        loginPresenter.startAuthorization()
        
        authenticationManager.observe?(OauthCredential(accessToken: ""),
                                       nil)
        XCTAssertTrue(loginViewMock.handleLoginSuccessCalled, "handle login success not called")
        XCTAssertFalse(loginViewMock.showErrorCalled, "show error called")
    }

    func testViewRespondsToFailure() {
        loginPresenter.startAuthorization()

        let error = NSError(domain: "0",
                            code: 0, userInfo: [NSLocalizedFailureErrorKey: "No token found"])
        authenticationManager.observe?(nil, error)

        XCTAssertTrue(loginViewMock.showErrorCalled, "show error not called")
        XCTAssertEqual(loginViewMock.errorString, "No token found")
    }
}
