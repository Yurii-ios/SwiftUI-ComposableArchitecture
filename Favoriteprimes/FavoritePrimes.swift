//
//  FavoritePrimes.swift
//  Favoriteprimes
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import Foundation
import SwiftUI
import Combine
import ComposableArchitecture

public enum FavoritePrimeAction: Equatable {
    case deleteFavoritePrimes(IndexSet)
    case loadFavoritePrimes([Int])
    case saveButtonTapped
    case loadButtonTapped
    
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimeAction) -> [Effect<FavoritePrimeAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            state.remove(at: index)
        }
        return []
        
    case let .loadFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []
        
    case .saveButtonTapped:
        return [
            Current.fileClient.save("favorite-primes.json", try! JSONEncoder().encode(state))
                .fireAndForget()
            //saveEffect(state)
        ]
        
    case .loadButtonTapped:
        return [
            Current.fileClient.load("favorite-primes.json")
                .compactMap { $0 }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { error in Empty(completeImmediately: true) }
                .map(FavoritePrimeAction.loadFavoritePrimes)
                .eraseToEffect()
            
            //loadEffect.compactMap { $0 }.eraseToEffect()
        ]
    }
}

extension Publisher where Output == Never, Failure == Never {
    func fireAndForget<A>() -> Effect<A> {
        return self.map(absurd).eraseToEffect()
    }
}

struct FileClient {
    var save: (String, Data) -> Effect<Never>
    var load: (String) -> Effect<Data?>
}

extension FileClient {
    static let userDefaults = FileClient(
        save: { fileName, data in
            return .fireAndForget {
                UserDefaults.standard.set(data, forKey: "FileClient:\(fileName)")
            }
        },
        load: { fileName -> Effect<Data?> in
                .sync {
                    UserDefaults.standard.data(forKey: "FileClient:\(fileName)")
                }
        })
}
//extension FileClient {
//    static let live = FileClient { fileName, data in
//        return Effect.fireAndForget {
//            let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let documentsUrl = URL(fileURLWithPath: documentPath)
//            let fovoritePrimesURL = documentsUrl.appendingPathComponent(fileName)
//            try! data.write(to: fovoritePrimesURL)
//            print("data: \(String(describing: data)) was saved")
//        }
//    } load: { fileName -> Effect<Data?> in
//        Effect<Data?>.sync {
//            let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let documentsUrl = URL(fileURLWithPath: documentPath)
//            let fovoritePrimesURL = documentsUrl.appendingPathComponent(fileName)
//
//            return try? Data(contentsOf: fovoritePrimesURL)
//        }
//    }
//}

// (Never) -> A
// func absurd<A>(_ never: Never) -> A {
//  switch never {}
//}

func absurd<A>(_ never: Never) -> A {}

struct FavoritePrimesEnvironment {
    var fileClient: FileClient
}

extension FavoritePrimesEnvironment {
    static let live = FavoritePrimesEnvironment(fileClient: .userDefaults)
}

var Current = FavoritePrimesEnvironment.live

#if DEBUG
extension FavoritePrimesEnvironment {
    static let mock = FavoritePrimesEnvironment(
        fileClient: FileClient(
            save: { _, _ in .fireAndForget {} },
            load: { _ in Effect<Data?>.sync { try! JSONEncoder().encode([2, 31]) } }
        )
    )
}
#endif
//struct Environment {
//    var date: () -> Date
//}
//
//extension Environment {
//    static let live = Environment(date: Date.init)
//}
//
//extension Environment {
//    static let moc = Environment(date: { Date.init(timeIntervalSince1970: 1234567890) } )
//}
//
//var current = Environment.live
//
//struct GitHubClient {
//  var fetchRepos: (@escaping (Result<[Repo], Error>) -> Void) -> Void
//
//  struct Repo: Decodable {
//    var archived: Bool
//    var description: String?
//    var htmlUrl: URL
//    var name: String
//    var pushedAt: Date?
//  }
//}
//
//#if DEBUG
//var Current = Environment.live
//#else
//let Current = Environment.live
//#endif

//private func saveEffect(_ favoritePrime: [Int]) -> Effect<FavoritePrimeAction> {
//    return Effect.fireAndForget {
//        let data = try? JSONEncoder().encode(favoritePrime)
//        let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let documentsUrl = URL(fileURLWithPath: documentPath)
//        let fovoritePrimesURL = documentsUrl.appendingPathComponent("favorite-primes.json")
//        try? data?.write(to: fovoritePrimesURL)
//        print("data: \(String(describing: data)) was saved")
//    }
//}
//
//private let loadEffect = Effect<FavoritePrimeAction?>.sync {
//    let documentPath =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//    let documentsUrl = URL(fileURLWithPath: documentPath)
//    let fovoritePrimesURL = documentsUrl.appendingPathComponent("favorite-primes.json")
//
//    guard let data = try? Data(contentsOf: fovoritePrimesURL),
//          let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data) else { return nil}
//
//    return .loadFavoritePrimes(favoritePrimes)
//}

public struct FavoriteView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimeAction>
    
    public init(store: Store<[Int], FavoritePrimeAction>) {
        self.store = store
    }
    
    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { prime in
                Text(prime.formatted())
            }
            .onDelete { indexSet in
                store.send(.deleteFavoritePrimes(indexSet))
                //self.store.send(.counter(.incrTapped))
            }
        }
        .navigationTitle("Favorite Primes")
        .toolbar {
            ToolbarItem(id: "Favorite Primes", placement: .navigationBarTrailing, showsByDefault: true) {
                HStack {
                    Button(action: { store.send(.saveButtonTapped) }) {
                        Text("Save")
                    }
                    Button(action: { store.send(.loadButtonTapped) }) {
                        Text("Load")
                    }
                }
            }
        }
    }
}

extension Effect {
    public static func sync(work: @escaping () -> Output) -> Effect {
        return Deferred {
            Just(work())
        }.eraseToEffect()
    }
}
