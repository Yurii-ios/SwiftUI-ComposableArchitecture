//
//  PrimeModelTests.swift
//  PrimeModelTests
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import XCTest
@testable import PrimeModel

final class PrimeModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSaveFavoritePrimesTapped() throws {
        var state = (counter: 3, favoritePrimes: [5,7])
        let effects = primeModalReducer(state: &state, action: .saveFavoritesPrimeTapped, environment: ())
        let (counter, favoritePrimes) = state
        XCTAssertEqual(state.counter, 3)
        XCTAssertEqual(state.favoritePrimes, [5, 7, 3])
        XCTAssert(effects.isEmpty)
    }
    
    func testRemoveFavoritePrimeTapped() {
        var state = (counter: 3, favoritePrimes: [3, 5])
        
        let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped, environment: ())
        
        let (count, favoritePrimes) = state
        XCTAssertEqual(state.counter, 3)
        XCTAssertEqual(state.favoritePrimes, [5])
        XCTAssert(effects.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
