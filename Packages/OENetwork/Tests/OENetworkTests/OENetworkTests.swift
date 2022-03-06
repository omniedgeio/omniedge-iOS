import Combine
@testable import OENetwork
import XCTest

final class OENetworkTests: XCTestCase {
    private var cancellables = [AnyCancellable]()
    #if false
    private let network = OENetwork(baseURL: "https://dev-api.omniedge.io/api/v1")
    #else
    private let network = OENetwork(baseURL: "https://api.omniedge.io/api/v1")
    #endif

    func testRegister() {
        let expectation = expectation(description: "wait for register")
        network.dispatch(TestRegisterRequst())
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                print("value: \(value)")
                XCTAssert(true, "register ok")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("register timeout: \(error)")
            }
        }
    }

    func testLogin() {
        let expectation = expectation(description: "wait for login")
        network.dispatch(TestLoginRequest())
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                print("value: \(value)")
                XCTAssertTrue(true, "login ok")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5) { (error: Error?) in
            if let error = error {
                XCTFail("timeout error: \(error)")
            }
        }
    }

    func testResetPassword() {
        let expectation = expectation(description: "wait for reset")
        network.dispatch(TestForgetPasswordRequest())
            .sink(receiveCompletion: { _ in }, receiveValue: { value in
                print("value: \(value)")
                XCTAssertTrue(true, "reset ok")
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5) { (error: Error?) in
            if let error = error {
                XCTFail("timeout error: \(error)")
            }
        }
    }
}

struct TestResult: Codable {
    var message: String?
    var data: [String: String]?
}

struct TestRegisterRequst: Request {
    typealias ReturnType = TestResult
    var path: String = "/auth/register"
    var body: [String: Any]? = ["name": "samuel1",
                                      "email": "samuel1@gmail.com",
                                      "password": "samuel@omniedge",
                                      "confirm_password": "samuel@omniedge"]
}

struct TestLoginRequest: Request {
    typealias ReturnType = TestResult
    var path: String = "/auth/login/password"
    var body: [String: Any]? = ["email": "john@gmail.com",
                                      "password": "JohnDoe1234$$",
                                      "auth_session_uuid": "e9497ac1-f33d-41d9-b868-ad1035854610"]
}

struct TestForgetPasswordRequest: Request {
    typealias ReturnType = TestResult
    var path: String = "/auth/reset-password/code"
    var body: [String: Any]? = ["email": "tangzhilin6@gmail.com"]
}
