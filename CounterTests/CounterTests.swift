//
//  CounterTests.swift
//  CounterTests
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import XCTest
@testable import Counter
import ComposableArchitecture
import CloudKit

func assert<Value, Action>(initialValue: Value, reducer: Reducer<Value, Action>, steps: [(action: Action, update: (inout Value) -> Void)]) {
    
}

final class CounterTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Current = .mock
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIncrementButtonTapped() throws {
        assert(initialValue: CounterViewState(count: 2), reducer: counterViewReducer, steps: [( .counter(.incrTapped), { $0.count = 3 })])
//        var state = CounterViewState(count: 2)
//        var expected = state
//        let effect =  counterViewReducer(&state, .counter(.incrTapped))
//        expected.count = 3
//
//        XCTAssertEqual(state, expected)
//        XCTAssertTrue(effect.isEmpty)
    }
    
    func testDecrementButtonTapped() throws {
        var state = CounterViewState(count: 2)
        var expected = state
        let effect =  counterViewReducer(&state, .counter(.decrTapped))
        expected.count = 1
        
        XCTAssertEqual(state, expected)
        XCTAssertTrue(effect.isEmpty)
    }
    
    func testNthPrimeButtonHappyFlow() {
        Current.nthPrime = { _ in .sync {
            17
        } }
        
        var state = CounterViewState(
            alertPrime: nil,
            isPrimeButtonDisabled: false
        )
        var expected = state
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        expected.isPrimeButtonDisabled = true
       
        XCTAssertEqual(state, expected)
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: CounterViewAction!
        let receivedCompletion = expectation(description: "receivedCompletion")
        effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            }, receiveValue: { action in
                // print(action)
                XCTAssertEqual(action, .counter(.nthPrimeResponce(17)))
                nextAction = action
            })
        
        wait(for: [receivedCompletion], timeout: 0.01)
        
        effects = counterViewReducer(&state, nextAction)
        
        expected.isPrimeButtonDisabled = false
        expected.alertPrime = 17
        
        XCTAssertEqual(state, expected)
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .counter(.alertDissmissButtonTapped))
        expected.alertPrime = nil
        
        XCTAssertEqual(state, expected)
        XCTAssert(effects.isEmpty)
    }
    
    func testNthPrimeButtonUnhappyFlow() {
        Current.nthPrime = { _ in .sync { nil }}
        
        var state = CounterViewState(
            isPrimeButtonDisabled: false
        )
        
        var expected = state
        
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        
        expected.isPrimeButtonDisabled = true
         
        XCTAssertEqual(state, expected)
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: CounterViewAction!
        let receivedCompletion = expectation(description: "receivedCompletion")
        effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            }, receiveValue: { action in
                // print(action)
                XCTAssertEqual(action, .counter(.nthPrimeResponce(nil)))
                nextAction = action
            })
        
        wait(for: [receivedCompletion], timeout: 0.01)
        
        effects = counterViewReducer(&state, nextAction)
        
        //effects = counterViewReducer(&state, .counter(.nthPrimeResponce(nil)))
        
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
            count: 2,
            favoritePrimes: [3, 5]
        )
        var expected = state
        var effects = counterViewReducer(&state, .primeModal(.saveFavoritesPrimeTapped))
        expected.favoritePrimes = [3, 5, 2]
        
        XCTAssertEqual(state, expected)
        XCTAssert(effects.isEmpty)
        
        effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))
        expected.favoritePrimes = [3, 5]
        
        XCTAssertEqual(state, expected)
        XCTAssert(effects.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
