import XCTest
import Mockingjay

class RequestProviderTest: XCTestCase {

    struct Person: Decodable, Equatable {
        var name: String
        var age: Int

        enum CodingKeys: CodingKey {
            case name, age
        }
    }

    var target: RequestTargetMock!
    var requestProvider: RequestProvider<RequestTargetMock>!

    override func setUp() {
        target = RequestTargetMock.sampleTarget(baseUrl: "https://localhost",
                                                params: [:],
                                                path: "/search",
                                                method: .get)
        requestProvider = RequestProvider<RequestTargetMock>()
    }

    override func tearDown() {
        target = nil
        requestProvider = nil
    }

    func testResponseJson() {
        let sampleJson = ["name": "Sandeep"]
        stub(everything, json(sampleJson))
        let expect = expectation(description: "Response json expectation")
        var outJson: Any?

        requestProvider.responseJSON(target: target) { response, _ in
            outJson = response
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)

        if let outJson = outJson as? [String: String] {
            XCTAssertEqual(outJson, sampleJson)
        } else {
            XCTFail("expected json output")
        }
    }

    func testInvalidJsonShouldCallbackError() {
        let mockingJayResponse = { (_: URLRequest) -> Response in
            let randomString = "Some random string"
            let data = randomString.data(using: .utf8)!

            let urlResponse = HTTPURLResponse(url: URL(string: "http://google.com")!,
                                              statusCode: 200,
                                              httpVersion: "1.1",
                                              headerFields: nil)
            return .success(urlResponse!, .content(data))
        }

        stub(everything, mockingJayResponse)

        let expect = expectation(description: "Invalid json error expected")
        var outJson: Any?
        var outError: Error?

        requestProvider.responseJSON(target: target) { response, error  in
            outJson = response
            outError = error
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        XCTAssertNil(outJson, "outJson is not nil")
        XCTAssertNotNil(outError)
    }

    func testResponseDecoding() {
        let sampleJson: [String: Any] = ["name": "Sandeep", "age": 28]
        stub(everything, json(sampleJson))

        var outPerson: Person?

        let expect = expectation(description: "Response person expectation")

        requestProvider.response(target: target) { (person: Person?, _) in
            outPerson = person
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)

        if let outPerson = outPerson {
            XCTAssertTrue(outPerson == Person(name: "Sandeep", age: 28),
                          "Decoded person is different")
        } else {
            XCTFail("outPerson is nil")
        }
    }

    func testResponseDecodingFailure() {
        let sampleJson: [String: Any] = ["name": "Sandeep", "Age": 28]
        stub(everything, json(sampleJson))

        var outPerson: Person?

        let expect = expectation(description: "Response person expectation")

        var outError: Error?
        requestProvider.response(target: target) { (person: Person?, error: Error?) in
            outError = error
            outPerson = person
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)
        XCTAssertNil(outPerson, "outPerson is not nil")
        XCTAssertNotNil(outError)
    }

    func testResponseShouldProvideResponseString() {
        let mockingJayResponse = { (_: URLRequest) -> Response in
            let randomString = "Some random string"
            let data = randomString.data(using: .utf8)!
            let urlResponse = HTTPURLResponse(url: URL(string: "http://google.com")!,
                                                   statusCode: 200,
                                                   httpVersion: "1.1",
                                                   headerFields: nil)
            return .success(urlResponse!, .content(data))
        }

        stub(everything, mockingJayResponse)

        var outError: Error?
        var outResponse: String?

        let expect = expectation(description: "Response string expectation")

        requestProvider.responseString(target: target) { responseString, error in
            outError = error
            outResponse = responseString
            expect.fulfill()
        }

        wait(for: [expect], timeout: 1.0)
        if let outResponse = outResponse {
            XCTAssertEqual(outResponse, "Some random string")
        } else {
            XCTFail("expected output response")
        }

        XCTAssertNil(outError, "outError is is not nil")
    }

    func testThatRequestProviderCallbacksOnError() {
        let error = NSError(domain: "SomeDomain",
                            code: 101,
                            userInfo: [NSLocalizedDescriptionKey: "Error happened"])
        stub(everything, failure(error))

        let expct = expectation(description: "Request expectation")

        var outError: Error?

        requestProvider.responseString(target: target) { _, error in
            outError = error
            expct.fulfill()
        }
        wait(for: [expct], timeout: 1.0)

        if let outError = outError {
            XCTAssertEqual(outError.localizedDescription, "Error happened")
        } else {
            XCTFail("Error is expected")
        }
    }
}
