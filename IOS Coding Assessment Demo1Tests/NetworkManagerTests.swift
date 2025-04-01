//
//  NetworkManagerTests.swift
//  IOS Coding Assessment Demo1Tests
//
//  Created by Kirsty Ihenetu on 3/29/25.
//

import XCTest
@testable import IOS_Coding_Assessment_Demo1

class NetworkManagerTests: XCTestCase {
    func testValidPostcode() async {
        let expectation = XCTestExpectation(description: "Fetch restaurants for N179RD")
        
        NetworkManager.shared.fetchRestaurants(postcode: "N179RD") { result in
            switch result {
            case .success(let restaurants):
                XCTAssert(!restaurants.isEmpty, "Should return at least 1 restaurant")
                expectation.fulfill()
            case .failure:
                XCTFail("Valid postcode should succeed")
            }
            expectation.fulfill()
        }
        await waitForExpectations(timeout: 5, handler: nil)
    }
    
}

