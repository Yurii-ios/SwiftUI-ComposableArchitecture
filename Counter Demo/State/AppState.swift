//
//  AppState.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import Foundation

class AppState: ObservableObject, Identifiable {
    @Published var counter = 0
    @Published var favoritePrimes: [Int] = []
    @Published var loggedInUser: User?
    @Published var activityFeed: [Activity] = []
    
    //var didChange = PassthroughSubject<Void, Never>()
}

extension AppState {
    func addFavoritePrime(count: Int) {
    self.favoritePrimes.append(count)
    self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(count)))
  }

  func removeFavoritePrime(_ prime: Int) {
    self.favoritePrimes.removeAll(where: { $0 == prime })
      self.activityFeed.append(Activity(timestamp: Date(), type: .removeFavoritePrime(prime)))
  }

  func removeFavoritePrime(count: Int) {
    self.removeFavoritePrime(count)
  }

  func removeFavoritePrimes(at indexSet: IndexSet) {
    for index in indexSet {
      self.removeFavoritePrime(self.favoritePrimes[index])
    }
  }
}
