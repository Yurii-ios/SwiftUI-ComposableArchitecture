//
//  RootView.swift
//  Counter_Demo
//
//  Created by Yurii.Semeliuk on 23/09/2022.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: EmptyView()) {
                Text("")
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
