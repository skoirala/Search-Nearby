import XCTest

class LoginServiceMock: OauthLoginServiceType {

    var accessTokenHandler: ((OauthCredential?, Error?) -> Void)?
    func startAuthorization() {

    }
    func handleOpen(url: URL) -> Bool {
        return true
    }
}

class OauthCredentialManagerTest: XCTestCase {

    var storage: MockedStorage!
    var mockedLogin: LoginServiceMock!
    var authenticationManager: OauthAuthenticationManager!

    override func setUp() {
        storage = MockedStorage()
        mockedLogin = LoginServiceMock()
        authenticationManager = OauthAuthenticationManager(storage: storage,
                                                           loginService: mockedLogin)
    }

    override func tearDown() {
        UserDefaults.resetStandardUserDefaults()
        storage = nil
        mockedLogin = nil
    }

    func testThatAccessTokenIsSaved() {
        let token = OauthCredential(accessToken: "123456")
        mockedLogin.accessTokenHandler?(token, nil)

        guard let credential = try? storage.credential() else {
            XCTFail("Failed credential must be stored")
            return
        }

        XCTAssertEqual(token.accessToken, credential.accessToken, "Store credential is not same as passed credential")
    }

    func testThatErrorHandlerIsCalled() {
        let error = NSError(domain: "OauthCredentialManager.test.domain",
                            code: 101,
                            userInfo: [NSLocalizedDescriptionKey: "OauthCredentialManager.test.domain Error occurred"])

        var receivedError: Error?

        authenticationManager.observe = { _, error in
            receivedError = error
        }

        mockedLogin.accessTokenHandler?(nil, error)

        guard let errorReceived = receivedError else {
            XCTFail("Error should be received when authentication manager gets error")
            return
        }

        XCTAssertEqual(errorReceived.localizedDescription, "OauthCredentialManager.test.domain Error occurred")
    }
}
