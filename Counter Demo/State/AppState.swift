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
}
