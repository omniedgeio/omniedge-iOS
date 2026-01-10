import XCTest
import Combine
@testable import OENetwork

final class OENetworkTests: XCTestCase {
    
    // Mock URLProtocol to intercept network calls
    class MockURLProtocol: URLProtocol {
        static var stubResponseData: Data?
        static var stubError: Error?
        static var stubResponse: HTTPURLResponse?
        static var lastRequest: URLRequest?

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            Self.lastRequest = request
            
            if let error = Self.stubError {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = Self.stubResponse {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = Self.stubResponseData {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        }

        override func stopLoading() {}
    }

    private var network: OENetwork!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let dispatcher = NetworkDispatcher(urlSession: session)
        network = OENetwork(baseURL: "https://api.test.com", dispatcher: dispatcher)
        
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubError = nil
        MockURLProtocol.stubResponse = nil
        MockURLProtocol.lastRequest = nil
    }

    func testAsyncDispatchSuccess() async throws {
        // Arrange
        let expectedData = TestResult(message: "Success", data: ["key": "value"])
        let encodedData = try JSONEncoder().encode(expectedData)
        
        MockURLProtocol.stubResponseData = encodedData
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act
        let result: TestResult = try await network.dispatch(TestMockRequest())
        
        // Assert
        XCTAssertEqual(result.message, "Success")
        XCTAssertEqual(result.data?["key"], "value")
        XCTAssertEqual(MockURLProtocol.lastRequest?.url?.path, "/test")
    }

    func testAsyncDispatchFailure() async throws {
        // Arrange
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Act & Assert
        do {
            let _: TestResult = try await network.dispatch(TestMockRequest())
            XCTFail("Should have thrown an error")
        } catch let error as NetworkRequestError {
            XCTAssertEqual(error, .unauthorized)
        } catch {
            XCTFail("Unexpected error type")
        }
    }

    func testCombineDispatchSuccess() {
        // Arrange
        let expectedData = TestResult(message: "Success", data: nil)
        let encodedData = try? JSONEncoder().encode(expectedData)
        
        MockURLProtocol.stubResponseData = encodedData
        MockURLProtocol.stubResponse = HTTPURLResponse(
            url: URL(string: "https://api.test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let expectation = self.expectation(description: "Combine Success")
        var cancellables = Set<AnyCancellable>()
        
        // Act
        network.dispatch(TestMockRequest())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Completed with error: \(error)")
                }
            }, receiveValue: { result in
                // Assert
                XCTAssertEqual(result.message, "Success")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
    }
}

// MARK: - Test Helpers

struct TestResult: Codable {
    var message: String?
    var data: [String: String]?
}

struct TestMockRequest: Request {
    typealias ReturnType = TestResult
    var path: String = "/test"
    var method: HTTPMethod = .get
}
