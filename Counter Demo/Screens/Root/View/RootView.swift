//
//  RootView.swift
//  Counter_Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(appState: appState)) {
                    Text("Counter Demo")
                        .font(.body)
                        .foregroundColor(.black)
                    
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes")
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
            .navigationTitle("Counter Demo")
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootView(appState: AppState())
                .environmentObject(AppState())
        }
    }
}
