//
//  OmniedgeTests.swift
//  OmniedgeTests
//
//  Created by samuelsong on 2021/4/22.
//

import XCTest
@testable import Omniedge

class OmniedgeTests: XCTestCase {
    private var engine: PacketTunnelEngine = PacketTunnelEngine();
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("Omniedge: test done\n");
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        self.engine.start();
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
