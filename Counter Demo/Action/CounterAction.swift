//
//  CounterAction.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 26/09/2022.
//

import Foundation
import Favoriteprimes
import Counter
import PrimeModel

enum AppAction: Equatable {
    case counterView(CounterFeatureAction)
    case offlineCounterView(CounterFeatureAction)
    case favoritePrimes(FavoritePrimeAction)
    
    var counterView: CounterFeatureAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimeAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
    
    var offlineCounterView: CounterFeatureAction? {
        get {
            guard case let .offlineCounterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
                self = .offlineCounterView(newValue)

        }
    }
}
