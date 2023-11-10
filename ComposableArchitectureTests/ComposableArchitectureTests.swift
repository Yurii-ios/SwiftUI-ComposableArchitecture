//
//  ComposableArchitectureTests.swift
//  ComposableArchitectureTests
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import XCTest
@testable import ComposableArchitecture
@testable import Counter_Demo
@testable import Counter
@testable import Favoriteprimes
@testable import PrimeModel
import ComposableArchitectureTestSupport


final class ComposableArchitectureTests: XCTestCase {
    func testIntegration() throws {
        var fileClient = FileClient.mock
        fileClient.load = { _ in
            Effect<Data?>.sync {
                try! JSONEncoder().encode([2,31])
            }
        }
        
        assert(
            initialValue: AppState(counter: 4),
            reducer: appReducer,
            environment: (
                fileClient: fileClient,
                nthPrime: { _ in .sync { 17}}
            ),
            steps:
            Step(type: .send, .counterView(.counter(.nthPrimeButtonTapped))) {
                    $0.isPrimeButtonDisabled = true
                },
            Step(type: .receive, .counterView(.counter(.nthPrimeResponce(4)))) {
                $0.isPrimeButtonDisabled = false
                $0.alertPrime = 4
            },
            Step(type: .send, .favoritePrimes(.loadButtonTapped)),
            Step(type: .send, .favoritePrimes(.loadFavoritePrimes([2, 31, 7]))) {
                $0.favoritePrimes = [2, 31, 7]
            }

        )
    }
}
