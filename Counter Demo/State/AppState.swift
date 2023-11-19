//
//  AppState.swift
//  Counter Demo
//
//  Created by Yurii.Sameliuk on 23/09/2022.
//

import Foundation
import Favoriteprimes
import PrimeModel
import Counter
import PrimeAler

struct AppState: Equatable {
    var counter = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    var alertPrime: PrimeAlert? = nil
    var isPrimeButtonDisabled: Bool = false
    
    //var didChange = PassthroughSubject<Void, Never>()
}

extension AppState {
    mutating func addFavoritePrime(count: Int) {
        self.favoritePrimes.append(count)
        self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(count)))
    }
    
    mutating func removeFavoritePrime(_ prime: Int) {
        self.favoritePrimes.removeAll(where: { $0 == prime })
        self.activityFeed.append(Activity(timestamp: Date(), type: .removeFavoritePrime(prime)))
    }
    
    mutating func removeFavoritePrime(count: Int) {
        self.removeFavoritePrime(count)
    }
    
    mutating func removeFavoritePrimes(at indexSet: IndexSet) {
        for index in indexSet {
            self.removeFavoritePrime(self.favoritePrimes[index])
        }
    }
}

extension AppState {
    var favoritePrimeState: FavoritePrimeState {
        get {
            (self.alertPrime, self.favoritePrimes)
        }
        set {
            (self.alertPrime, self.favoritePrimes) = newValue
        }
    }
    
    var counterView: CounterFeatureState {
        get {
            CounterFeatureState(alertPrime: alertPrime?.prime, count: counter, favoritePrimes: favoritePrimes, isPrimeButtonDisabled: isPrimeButtonDisabled)
        }
        set {
            self.alertPrime?.prime  = newValue.alertPrime ?? 0
            self.counter = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.isPrimeButtonDisabled = newValue.isPrimeButtonDisabled
        }
    }
}

//extension AppState {
//    var favoritePrimesState: FavoritePrimesState {
//        get {
//            FavoritePrimesState(favoritePrimes: favoritePrimes, activityFeed: activityFeed)
//        }
//        set {
//            favoritePrimes = newValue.favoritePrimes
//            activityFeed = newValue.activityFeed
//        }
//    }
//}


//struct UndoState<Value> {
//  var value: Value
//  var history: [Value]
//  var undone: [Value]
//  var canUndo: Bool { !self.history.isEmpty }
//  var canRedo: Bool { !self.undone.isEmpty }
//}
//
//enum UndoAction<Action> {
//  case action(Action)
//  case undo
//  case redo
//}
//
//func undo<Value, Action>(
//  _ reducer: @escaping (inout Value, Action) -> Void,
//  limit: Int
//) -> (inout UndoState<Value>, UndoAction<Action>) -> Void {
//  return { undoState, undoAction in
//    switch undoAction {
//    case let .action(action):
//      var currentValue = undoState.value
//      reducer(&currentValue, action)
//      undoState.history.append(currentValue)
//      undoState.undone = []
//      if undoState.history.count > limit {
//        undoState.history.removeFirst()
//      }
//    case .undo:
//      guard undoState.canUndo else { return }
//      undoState.undone.append(undoState.value)
//      undoState.value = undoState.history.removeLast()
//    case .redo:
//      guard undoState.canRedo else { return }
//      undoState.history.append(undoState.value)
//      undoState.value = undoState.undone.removeFirst()
//    }
//  }
//}
