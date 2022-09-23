//
//  PrimeSheetView.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct PrimeSheetView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack {
            if isPrime(appState.counter) {
                Text("\(appState.counter) is prime")
                if appState.favoritePrimes.contains(appState.counter) {
                    Button(action: {
                        appState.favoritePrimes.removeAll(where: { $0 == appState.counter })
                    }) {
                        Text("Remove from favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                } else {
                    Button(action: {
                        appState.favoritePrimes.append(appState.counter)
                    }) {
                        Text("Save to favorite primes")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.automatic)
                }
            } else {
                Text("\(appState.counter) is not prime")
            }
        }
    }
    
    private func isPrime(_ number: Int) -> Bool {
        if number <= 1 { return false }
        if number <= 3 { return true }
        
        for i in 2...Int(sqrtf(Float(number))) {
            if number % i == 0 { return false }
        }
        return true
    }
}

struct PrimeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PrimeSheetView(appState: AppState())
    }
}
