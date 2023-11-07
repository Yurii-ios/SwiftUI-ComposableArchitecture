//
//  FavoriteprimesTests.swift
//  FavoriteprimesTests
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import XCTest
@testable import Favoriteprimes

final class FavoriteprimesTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        Current = .mock
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDeleteButtonTapped() {
        var state = [2, 3, 5, 7]
        
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))
        
        XCTAssertEqual(state, [2, 3, 7])
        XCTAssert(effects.isEmpty) // ?
    }
    
    func testSaveButtonTapped() {
        var didSave = false
        
        Current.fileClient.save = { _, _ in
                .fireAndForget {
                    didSave = true
                }
        }
        
        var state = [2, 3, 5, 7]
        
        let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)
        
        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        effects[0].sink { _ in XCTFail() }
        XCTAssert(didSave)
    }
    
    func testLoadFavoritePrimesFlow() {
        Current.fileClient.load = { _ in .sync { try! JSONEncoder().encode([2, 31]) } }
        var state = [2, 3, 5, 7]
        
        var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)
        
        XCTAssertEqual(state, [2, 3, 5, 7])
        XCTAssertEqual(effects.count, 1)
        
        var nextAction: FavoritePrimeAction!
        let recivedCompletion = self.expectation(description: "recivedCompletion")
        _ = effects[0].sink(receiveCompletion: { _ in
            recivedCompletion.fulfill()
        }, receiveValue: { action in
            //print(action)
            XCTAssertEqual(action, .loadFavoritePrimes([2, 31]))
            nextAction = action
        })
        wait(for: [recivedCompletion], timeout: 0)
        
        effects = favoritePrimesReducer(state: &state, action: nextAction)
        
        XCTAssertEqual(state, [2, 31])
        XCTAssert(effects.isEmpty)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
