//
//  AppState.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import Foundation

struct AppState {
    var counter = 0
    var favoritePrimes: [Int] = []
    var loggedInUser: User?
    var activityFeed: [Activity] = []
    
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
