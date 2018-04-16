import XCTest

import Mockingjay

class LoginHandlerTest: XCTestCase {

    func testLoginHandlerCannotHandleAppSchemeWithoutCode() {
        let loginService = OauthLoginService()
        let url = URL(string: "searchnearby://authorize")!

        let status = loginService.handleOpen(url: url)

        XCTAssertFalse(status, "did handle url \(url)")
    }

    func testLoginHandlerCanHandleAppSchemeWithCode() {
        let loginService = OauthLoginService()
        let url = URL(string: "searchnearby://authorize?code=98382872")!

        let status = loginService.handleOpen(url: url)

        XCTAssertTrue(status, "did not handle url \(url)")
    }

    func testLoginHandlerCannnotHandleUrlOtherSchemes() {

        let loginService = OauthLoginService()
        let url = URL(string: "http://google.com")!

        let status = loginService.handleOpen(url: url)

        XCTAssertFalse(status, "did handle url \(url)")
    }

    func testLoginHandlerWithProperSchemeShouldCallHandlingForCode() {

        class CustomLoginService: OauthLoginService {
            var codeReceived: String!

            override func handleAuthentication(code: String) {
                codeReceived = code
            }
        }

        let loginService = CustomLoginService()
        let url = URL(string: "searchnearby://authorize?code=98382872")!

        _ = loginService.handleOpen(url: url)
        XCTAssertEqual(loginService.codeReceived, "98382872")
    }

    func testLoginHandlerCallsbackWithProperAccessTokenFromRestApi() {
        let accessTokenJson = [ "accessToken": "18739203" ]
        stub(everything, json(accessTokenJson))

        let loginService = OauthLoginService()
        let url = URL(string: "searchnearby://authorize?code=98382872")!
        var oauthCredential: OauthCredential?

        let expect = expectation(description: "Oauth token callback")

        loginService.accessTokenHandler = { credential, _ in
            oauthCredential = credential
            expect.fulfill()
        }

        let status = loginService.handleOpen(url: url)
        wait(for: [expect], timeout: 1.0)

        XCTAssertTrue(status, "LoginService should handle url with proper code")

        guard let receivedCredential = oauthCredential else {
            XCTFail("Must receive credential")
            return
        }
        XCTAssertEqual(receivedCredential.accessToken, "18739203")
    }

    func testLoginHandlerCallsbackWithProperError() {
        let error = NSError(domain: "accessTokenDomain",
                            code: 101,
                            userInfo: [NSLocalizedDescriptionKey: "Oauth access token error"])
        stub(everything, failure(error))

        let loginService = OauthLoginService()
        let url = URL(string: "searchnearby://authorize?code=98382872")!

        var oauthCredential: OauthCredential?
        var outputError: Error?

        let expect = expectation(description: "Oauth token callback")
        loginService.accessTokenHandler = { credential, outError in
            oauthCredential = credential
            outputError = outError
            expect.fulfill()
        }

        let status = loginService.handleOpen(url: url)
        wait(for: [expect], timeout: 1.0)

        XCTAssertTrue(status, "cannot handle url")
        XCTAssertNil(oauthCredential, "credentials must be nil when error")

        guard let outError = outputError else {
            XCTFail("outError must be set")
            return
        }

        XCTAssertEqual(outError.localizedDescription, "Oauth access token error")
    }
}
