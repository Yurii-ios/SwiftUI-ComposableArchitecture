//
//  ComposableArchitecture.swift
//  
//
//  Created by Yurii Sameliuk on 04/10/2022.
//

import Combine

public typealias Effect<Action> = () -> Action?
public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action>
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    
    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
        // self.objectWillChange // ObservableObjectPublisher
        // self.$value // Published<Value>.Publisher
        // self.$value.sink(receiveValue: ((Value) -> Void))
        self.value = initialValue
        self.reducer = reducer
    }
    
    public func send(_ action: Action) {
        let effects = reducer(&value, action)
        effects.forEach { effect in
            if let action = effect() {
                send(action)
            }
        }
    }
    
    // ((Value) -> LocalValue) -> ((Store<Value, _>) -> Store<LocalValue, _>
    // ((A) -> B) -> ((Store<A, _>) -> Store<B, _>)
    // ((A) -> B) -> ((F<A>) -> F<B>)
    // map: ((A) -> B) -> ((F<A>) -> F<B>)
    public func view<LocalValue, LocalAction>(value toLocalValue: @escaping (Value) -> LocalValue, action toGlobalAction: @escaping(LocalAction) -> Action) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(initialValue: toLocalValue(self.value), reducer: { localValue, localAction in
            self.send(toGlobalAction(localAction))
            localValue = toLocalValue(self.value)
            return []
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
    _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
    
    return { value, action in
        //        var effects: [Effect] = []
        //        for reducer in reducers {
        //            let effect = reducer(&value, action)
        //            effects.append(effect)
        //        }
        let effects = reducers.flatMap{ $0(&value, action) }
        return effects
//        return { () -> Action? in
//            for effect in effects {
//                let action = effect()
//                return action
//            }
//        }
    }
}

public func logging<Value, Action>(
    _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
    return { value, action in
        let effects = reducer(&value, action)
        let newValue = value
        return [{
            print("Action: \(action)")
            print("Value:")
            dump(newValue)
            print("---")
            return nil
        }] + effects
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
    return { globalValue, globalAction in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction)
        
        return localEffects.map { localEffect in
            { () -> GlobalAction? in
                guard let localAction = localEffect() else { return nil }
                
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
        }
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
