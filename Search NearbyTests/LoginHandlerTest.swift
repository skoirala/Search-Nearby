import XCTest

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
}
