//
//  Counter.swift
//  Counter Demo
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture
import PrimeModel

public enum CounterAction {
    case decrTapped
    case incrTapped
}

public func counterReducer(state: inout Int, action: CounterAction) {
    switch action {
    case .decrTapped:
        state -= 1
        
    case .incrTapped:
        state += 1
    }
}

// @ObservedObject var state: AppState ->  @ObservedObject var store: Store<AppState>
public typealias CounterViewState = (counter: Int, favoritePrimes: [Int])

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
}

public struct CounterView: View {
    @ObservedObject var store: Store<CounterViewState, CounterViewAction>
    @State private var isPrimeSheetPresented: Bool = false
    @State private var isAlertPrimePresented: Bool = false
    @State private var alertPrimeNumber: Int?
    @State private var isPrimeButtonDisabled: Bool = false
    
    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }
    
    public  var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                actionView(title: "-", action: {
                    if store.value.counter > 0 {
                        store.send(.counter(.decrTapped))
                        //store.value.counter -= 1
                    }
                })
                Text(store.value.counter.formatted())
                    .sheet(isPresented: $isPrimeSheetPresented, onDismiss: nil) {
                        PrimeSheetView(store: store.view(value:{ appState in
                            return (appState.counter, appState.favoritePrimes)
                        }, action: { localAction in
                            CounterViewAction.primeModal(localAction)
                        }))
                    }
                    .foregroundColor(.black)
                
                actionView(title: "+", action: {
                    store.send(.counter(.incrTapped))
                    //store.value.counter += 1
                })
            }
            
            actionView(title: "Is this prime?", action: {
                isPrimeSheetPresented = true
            })
            .padding(.vertical, 5)
            .alert("Prime", isPresented: $isAlertPrimePresented) {
                Button(role: .cancel) {} label: {
                    Text("OK")
                }
            } message: {
                if let alertPrimeNumber = alertPrimeNumber {
                    Text("The \(store.value.counter)th prime is \(alertPrimeNumber)")
                }
            }
            
            actionView(title: "What is the \(store.value.counter.formatted())th prime?", action: {
                isPrimeButtonDisabled = true
                nthPrime(store.value.counter) { prime in
                    alertPrimeNumber = prime
                    isPrimeButtonDisabled = false
                    isAlertPrimePresented = true
                }
            })
            .disabled(isPrimeButtonDisabled)
        }
        .font(.title3)
    }
    
    @ViewBuilder
    func actionView(title: String, action: @escaping ()-> ()) -> some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(.automatic)
    }
}
