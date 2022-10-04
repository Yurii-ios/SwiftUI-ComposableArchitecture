//
//  CounterView.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

// @ObservedObject var state: AppState ->  @ObservedObject var store: Store<AppState>

struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State private var isPrimeSheetPresented: Bool = false
    @State private var isAlertPrimePresented: Bool = false
    @State private var alertPrimeNumber: Int?
    @State private var isPrimeButtonDisabled: Bool = false
    
    var body: some View {
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
                        PrimeSheetView(store: store)
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

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(store: Store(initialValue: AppState(), reducer: activityFeed(appReducer)))
            .environmentObject(Store(initialValue: AppState(), reducer: activityFeed(appReducer)))
    }
}
