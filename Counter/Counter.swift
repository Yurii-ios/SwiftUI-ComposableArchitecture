//
//  Counter.swift
//  Counter Demo
//
//  Created by Yurii Sameliuk on 05/10/2022.
//

import SwiftUI
import Combine
import ComposableArchitecture
import PrimeModel
import PrimeAler

public enum CounterAction: Equatable {
    case decrTapped
    case incrTapped
    case nthPrimeButtonTapped
    case nthPrimeResponce(n: Int, prime: Int?)
    case alertDissmissButtonTapped
}

public typealias CounterSate = (
    alertPrime: PrimeAlert?,
    count: Int,
    isNthPrimeRequestFlight: Bool
)

public func counterReducer(
    state: inout CounterSate,
    action: CounterAction,
    environment: CounterEnvironment
) -> [Effect<CounterAction>] {
    switch action {
    case .decrTapped:
        state.count -= 1
        return []
        
    case .incrTapped:
        state.count += 1
        return []
        
    case .nthPrimeButtonTapped:
        state.isNthPrimeRequestFlight = true
        let n = state.count
        return [
            //nthPrime(state.count)
            environment(state.count)
                .map { CounterAction.nthPrimeResponce(n: n, prime: $0) }
                .receive(on: DispatchQueue.main, options: nil)
                .eraseToEffect()
            //            { callback in
            //            nthPrime(counter) { prime in
            //                DispatchQueue.main.async {
            //                    callback(.nthPrimeResponce(prime))
            //                }
            //              ⬆️ UI will be updated much faster
            //callback(.nthPrimeResponce(prime)) //  this code is executed in bg thred
            //            }
            
            //            var p: Int?
            //            let sema = DispatchSemaphore(value: 0)
            //            nthPrime(counter) { prime in
            //                p = prime
            //                sema.signal()
            //            }
            //            sema.wait()
            //            return.nthPrimeResponce(p)
            //        }
        ]
        
    case let .nthPrimeResponce(n, prime):
        state.alertPrime = prime.map { PrimeAlert(n: n, prime: $0) }
        state.isNthPrimeRequestFlight = false
        return []
        
    case .alertDissmissButtonTapped:
        state.alertPrime = nil // add this line to help fix the bug. when we press the prime button once we cant press it again
        return []
    }
}

//public struct CounterEnvironment {
//    var nthPrime: (Int) -> Effect<Int?>
//}

public typealias CounterEnvironment = (Int) -> Effect<Int?>

//extension CounterEnvironment {
//    public static let live = CounterEnvironment(nthPrime: Counter.nthPrime)
//}

//var Current = CounterEnvironment.live

//#if DEBUG
//extension CounterEnvironment {
//    static let mock = CounterEnvironment(nthPrime: { _ in  .sync { 17 }})
//}
//#endif

public func nthPrime(_ n: Int) -> Effect< Int?> {
    return wolframAlpha(query: "prime \(n)").map { result in
        result
            .flatMap {
                $0.queryresult
                    .pods
                    .first(where: { $0.primary == .some(true) })?
                    .subpods
                    .first?
                    .plaintext
            }
            .flatMap(Int.init)
    }
    .eraseToEffect()
}

public func offlineNthPrime(_ n: Int) -> Effect<Int?> {
  Future { callback in
    var nthPrime = 1
    var count = 0
    while count <= n {
      nthPrime += 1
      if isPrime(nthPrime) {
        count += 1
      }
    }
    callback(.success(nthPrime))
  }
  .subscribe(on: DispatchQueue.global())
  .receive(on: DispatchQueue.main)
  .eraseToEffect()
}


public let counterViewReducer: Reducer<CounterFeatureState, CounterFeatureAction, CounterEnvironment> = combine(
    pullback(
        counterReducer,
        value: \CounterFeatureState.counter,
        action: \CounterFeatureAction.counter,
        environment: { $0 }
    ),
    pullback(
        primeModalReducer,
        value: \.primeModal,
        action: \.primeModal,
        environment: { _ in () }
    )
)

// @ObservedObject var state: AppState ->  @ObservedObject var store: Store<AppState>
public struct CounterFeatureState: Equatable {
    public var alertPrime: PrimeAlert?
    public var count: Int
    public var favoritePrimes: [Int]
    //public var isPrimeButtonDisabled: Bool
    public var isNthPrimeRequestFlight: Bool
    public var isPrimeModalShown: Bool
    
    
    var counter: CounterSate {
        get {
            (self.alertPrime, self.count, self.isNthPrimeRequestFlight)
        }
        set {
            (self.alertPrime, self.count, self.isNthPrimeRequestFlight) = newValue
        }
    }
    
    var primeModal: PrimeModalState {
        get {
            (self.count, self.favoritePrimes)
        }
        set {
            (self.count, self.favoritePrimes) = newValue
        }
    }
    
    public init(alertPrime: PrimeAlert? = nil, count: Int = 0, favoritePrimes: [Int] = [], isNthPrimeRequestFlight: Bool = false, isPrimeModalShown: Bool = false) {
        self.alertPrime = alertPrime
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.isNthPrimeRequestFlight = isNthPrimeRequestFlight
        self.isPrimeModalShown = isPrimeModalShown
    }
}

public enum CounterFeatureAction: Equatable {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    
    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
    
}

public struct CounterView: View {
    struct States: Equatable {
        let alertNthPrime: PrimeAlert?
        let count: Int
        let isPrimeButtonDisabled: Bool
        let isIncrementButtonDisabled: Bool
        let isDecrementButtondisabled: Bool
    }
    let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject var viewStore: ViewStore<States>
    @State private var isPrimeSheetPresented: Bool = false
    @State private var isAlertPrimePresented: Bool = false
    //    @State private var alertPrimeNumber: Int?
    //    @State private var isPrimeButtonDisabled: Bool = false
    
    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        self.store = store
        self.viewStore = self.store
            .scope(value: States.init(counterFeatureState: ), action: { $0 })
            .view
    }
    
    public  var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                actionView(title: "-", action: {
                    if viewStore.value.count > 0 {
                        store.send(.counter(.decrTapped))
                        //store.value.counter -= 1
                    }
                })
                .disabled(self.viewStore.value.isDecrementButtondisabled)
                Text(viewStore.value.count.formatted())
                    .sheet(isPresented: $isPrimeSheetPresented, onDismiss: nil) {
                        PrimeSheetView(store: store.scope(value:{ appState in
                            return (appState.count, appState.favoritePrimes)
                        }, action: { localAction in
                            CounterFeatureAction.primeModal(localAction)
                        }))
                    }
                    .foregroundColor(.black)
                
                actionView(title: "+", action: {
                    store.send(.counter(.incrTapped))
                    //store.value.counter += 1
                })
                .disabled(self.viewStore.value.isIncrementButtonDisabled)
            }
            
            actionView(title: "Is this prime?", action: {
                isPrimeSheetPresented = true
            })
            .padding(.vertical, 5)
            .alert("Prime", isPresented: Binding.constant(viewStore.value.alertNthPrime != nil)) {
                Button(role: .cancel) {
                    store.send(.counter(.alertDissmissButtonTapped))
                } label: {
                    Text("OK")
                }
            } message: {
                if let alertPrimeNumber = viewStore.value.alertNthPrime {
                    Text("The \(viewStore.value.count)th prime is \(alertPrimeNumber.prime)")
                }
            }
            
            actionView(title: "What is the \(viewStore.value.count.formatted())th prime?", action: {
                store.send(.counter(.nthPrimeButtonTapped))
                //                isPrimeButtonDisabled = true
                //                nthPrime(store.value.counter) { prime in
                //                    alertPrimeNumber = prime
                //                    isPrimeButtonDisabled = false
                //                    isAlertPrimePresented = true
            })
            .disabled(viewStore.value.isPrimeButtonDisabled)
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

extension CounterView.States {
    init(counterFeatureState: CounterFeatureState) {
        self.alertNthPrime = counterFeatureState.alertPrime
        self.count = counterFeatureState.count
        self.isPrimeButtonDisabled = counterFeatureState.isNthPrimeRequestFlight
        self.isIncrementButtonDisabled = counterFeatureState.isNthPrimeRequestFlight
        self.isDecrementButtondisabled = counterFeatureState.isNthPrimeRequestFlight
    }
}
