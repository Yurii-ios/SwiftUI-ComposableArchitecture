//
//  CounterView.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct CounterView: View {
    @ObservedObject var appState: AppState
    @State private var isPrimeSheetPresented: Bool = false
    @State private var isAlertPrimePresented: Bool = false
    @State private var alertPrimeNumber: Int?
    @State private var isPrimeButtonDisabled: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                actionView(title: "-", action: {
                    if appState.counter > 0 {
                        appState.counter -= 1
                    }
                })
                Text(appState.counter.formatted())
                    .sheet(isPresented: $isPrimeSheetPresented, onDismiss: nil) {
                        PrimeSheetView(appState: appState)
                    }
                    .foregroundColor(.black)
                
                actionView(title: "+", action: {
                    appState.counter += 1
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
                    Text("The \(appState.counter)th prime is \(alertPrimeNumber)")
                }
            }
            
            actionView(title: "What is the \(appState.counter.formatted())th prime?", action: {
                isPrimeButtonDisabled = true
                nthPrime(appState.counter) { prime in
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
        CounterView(appState: AppState())
            .environmentObject(AppState())
    }
}
