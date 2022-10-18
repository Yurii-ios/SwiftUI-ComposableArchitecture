//
//  CounterTests.swift
//  CounterTests
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import XCTest
@testable import Counter

final class CounterTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIncrementButtonTapped() throws {
        var state = CounterViewState(alertPrime: nil, count: 2, favoritePrimes: [3,5], isPrimeButtonDisabled: false)
        let effect =  counterViewReducer(&state, .counter(.incrTapped))
        XCTAssertEqual(state, CounterViewState(alertPrime: nil, count: 3, favoritePrimes: [3,5], isPrimeButtonDisabled: false))
        XCTAssertTrue(effect.isEmpty)
    }
    
    func testDecrementButtonTapped() throws {
        var state = CounterViewState(alertPrime: nil, count: 2, favoritePrimes: [3,5], isPrimeButtonDisabled: false)
        let effect =  counterViewReducer(&state, .counter(.decrTapped))
        XCTAssertEqual(state, CounterViewState(alertPrime: nil, count: 1, favoritePrimes: [3,5], isPrimeButtonDisabled: false))
        XCTAssertTrue(effect.isEmpty)
    }
    
    func testNthPrimeButtonHappyFlow() {
        var state = CounterViewState(
            alertPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isPrimeButtonDisabled: false
        )
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: true
            )
        )
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponce(3)))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: 3,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .counter(.alertDissmissButtonTapped))
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        var state = CounterViewState(
            alertPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isPrimeButtonDisabled: false
        )
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: true
            )
        )
        XCTAssertEqual(effects.count, 1)
        
        effects = counterViewReducer(&state, .counter(.nthPrimeResponce(nil)))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
    
    func testPrimeModal() {
        var state = CounterViewState(
            alertPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isPrimeButtonDisabled: false
        )
        
        var effects = counterViewReducer(&state, .primeModal(.saveFavoritesPrimeTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5, 2],
                isPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
