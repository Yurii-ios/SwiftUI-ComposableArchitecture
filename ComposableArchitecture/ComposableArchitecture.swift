//
//  ComposableArchitecture.swift
//  
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import Combine

public final class Store<Value, Action>: ObservableObject {
    private let reducer: (inout Value, Action) -> Void
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    
    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        // self.objectWillChange // ObservableObjectPublisher
        // self.$value // Published<Value>.Publisher
        // self.$value.sink(receiveValue: ((Value) -> Void))
        self.value = initialValue
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        reducer(&value, action)
    }
    
    // ((Value) -> LocalValue) -> ((Store<Value, _>) -> Store<LocalValue, _>
    // ((A) -> B) -> ((Store<A, _>) -> Store<B, _>)
    // ((A) -> B) -> ((F<A>) -> F<B>)
    // map: ((A) -> B) -> ((F<A>) -> F<B>)
    public func view<LocalValue, LocalAction>(value toLocalValue: @escaping (Value) -> LocalValue, action toGlobalAction: @escaping(LocalAction) -> Action) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(initialValue: toLocalValue(self.value), reducer: { localValue, localAction in
            self.send(toGlobalAction(localAction))
            localValue = toLocalValue(self.value)
        })
        
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        
        return localStore
    }
    
    // ((LocalAction) -> Action) -> ((Store<_, Action>) -> Store<_, LocalAction>)
    // ((B) -> A) -> ((Store<A, _>) -> Store<B, _>)
    // ((B) -> A) -> (F<A>) -> F<B>)
    // pullback: ((A) -> B) -> (F<B>) -> F<A>)
//    public func view<LocalAction>(_ f: @escaping (LocalAction) -> Action) -> Store<Value, LocalAction> {
//        return Store<Value, LocalAction>(initialValue: self.value, reducer: { value, localAction in
//            //self.send(f(action))
//            value = self.value
//        }
//        )
//      }
}

func transform<A, B, Action>(
    _ reducer: (A, Action) -> A,
    _ f: (A) -> B
) -> (B, Action) -> B {
    fatalError()
}

public func combine<Value, Action>(
    _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {
    
    return { value, action in
        for reducer in reducers {
            reducer(&value, action)
        }
    }
}

public func logging<Value, Action>(
    _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
    return { value, action in
        reducer(&value, action)
        print("Action: \(action)")
        print("Value:")
        dump(value)
        print("---")
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return }
        reducer(&globalValue[keyPath: value], localAction)
    }
}


//func pullback<Value, GlobalAction, LocalAction>(
//  _ reducer: @escaping (inout Value, LocalAction) -> Void,
//  action: WritableKeyPath<GlobalAction, LocalAction?>
//) -> (inout Value, GlobalAction) -> Void {
//
//  return { value, globalAction in
//    guard let localAction = globalAction[keyPath: action] else { return }
//    reducer(&value, localAction)
//  }
//}
