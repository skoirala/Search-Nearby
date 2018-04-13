import XCTest

@testable import Search_Nearby

class RequestTargetTest: XCTestCase {

    func testUrlAppendsPath() {
        let target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: [:],
                                                    path: "/search",
                                                    method: .get)
        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search")
        } else {
            XCTFail("requestUrl must not be nil")
        }
    }

    func testUrlAppendsParamsForGet() {
        let target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something"],
                                                    path: "/search",
                                                    method: .get)
        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search?q=something")
        } else {
            XCTFail("requestUrl must not be nil")
        }
    }

    func testUrlAppendsMultipleParamsForGet() {
        let target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something",
                                                             "context": "iOSApp"],
                                                    path: "/search",
                                                    method: .get)
        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search?q=something&context=iOSApp")
        } else {
            XCTFail("requestUrl must not be nil")
        }
    }

    func testUrlDontAppendParamsToPath() {
        var target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something"],
                                                    path: "/search",
                                                    method: .post)
        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search")
        } else {
            XCTFail("requestUrl should not be nil")
        }

        target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something"],
                                                    path: "/search",
                                                    method: .put)

        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search")
        } else {
            XCTFail("requestUrl should not be nil")
        }

        target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                params: ["q": "something"],
                                                path: "/search",
                                                method: .delete)

        if let requestUrl = target.requestUrl?.absoluteString {
            XCTAssertEqual(requestUrl, "https://localhost/search")
        } else {
            XCTFail("requestUrl should not be nil")
        }
    }

    func testUrlParamsForPostIsAppenededToBody() {
        let target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something"],
                                                    path: "/search",
                                                    method: .put)
        if let request = target.urlRequest,
            let body = request.httpBody {
            let queryString = String(data: body, encoding: .utf8)!
            XCTAssertEqual(queryString, "q=something")

        } else {
            XCTFail("request and httpBody must exist")
        }
    }

    func testMultipleUrlParamsForPostIsAppenededToBody() {
        let target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                    params: ["q": "something",
                                                             "context": "iosApp"],
                                                    path: "/search",
                                                    method: .put)
        if let request = target.urlRequest,
            let body = request.httpBody {
            let queryString = String(data: body, encoding: .utf8)!
            XCTAssertEqual(queryString, "q=something&context=iosApp")

        } else {
            XCTFail("request and httpBody must exist")
        }
    }
}
