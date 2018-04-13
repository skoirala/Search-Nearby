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

    func handleLoginSuccess(with token: OauthCredential) {
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

    override func setUp() {
        loginViewMock = LoginViewTypeMock()
        authenticationManager = UserCredentialManagerMock()

        let window = UIWindow()
        let storage = AppKeyValueStorage()
        let router = Router(window: window,
                            storage: storage)

        loginPresenter = LoginViewPresenter(router: router,
                                            storage: storage,
                                            authenticationManager: authenticationManager)
        loginPresenter.attach(view: loginViewMock)
    }

    override func tearDown() {
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
