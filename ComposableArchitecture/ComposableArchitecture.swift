import Combine
import SwiftUI

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
}

//DispatchQueue.main.async(execute: () -> Void) -> Void
//UIView.animate(withDuration: TimeInterval, animations: () -> Void) -> Void
//URLSession.shared.dataTask(with: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void) -> Void

//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void
//public struct Effect<A> {
//    public let run: (@escaping (A) -> Void) -> Void
//
//    public init(run: @escaping (@escaping (A) -> Void) -> Void) {
//        self.run = run
//    }
//
//    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
//        return Effect<B> { callback in self.run { a in callback(f(a)) }
//        }
//    }
//}

public struct Effect<Output>: Publisher {
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
}

public typealias Reducer<Value, Action, Environment> = (inout Value, Action, Environment) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
    private let reducer: Reducer<Value, Action, Void>
    private let environment: Any
    @Published public private(set) var value: Value
    private var viewCancellable: Cancellable?
    private var effectCancellables: Set<AnyCancellable> = []
    
    public init<Environment>(
        initialValue: Value,
        reducer: @escaping Reducer<Value, Action, Environment>,
        environment: Environment
    ) {
        // self.objectWillChange // ObservableObjectPublisher
        // self.$value // Published<Value>.Publisher
        // self.$value.sink(receiveValue: ((Value) -> Void))
        self.value = initialValue
        self.reducer = { value, action, _ in
            reducer(&value, action, environment)
        }
        self.environment = environment
    }
    
    public func send(_ action: Action) {
        let effects = reducer(&value, action, ())
        
        effects.forEach { effect in
            var effectCancellable:  AnyCancellable?
            var didComplete: Bool = false
            effectCancellable = effect.sink(receiveCompletion: { [weak self] _ in
                didComplete = true
                guard let effectCancellable = effectCancellable else { return }
                self?.effectCancellables.remove(effectCancellable)
            },receiveValue: send)
            
            if !didComplete, let effectCancellable = effectCancellable {
                effectCancellables.insert(effectCancellable)
            }
        }
        //        DispatchQueue.global().async {
        //          effects.forEach { effect in
        //            if let action = effect() {
        //              DispatchQueue.main.async {
        //                self.send(action)
        //              }
        //            }
        //          }
        //        }
    }
    
    // ((Value) -> LocalValue) -> ((Store<Value, _>) -> Store<LocalValue, _>
    // ((A) -> B) -> ((Store<A, _>) -> Store<B, _>)
    // ((A) -> B) -> ((F<A>) -> F<B>)
    // map: ((A) -> B) -> ((F<A>) -> F<B>)
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
      ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
          initialValue: toLocalValue(self.value),
          reducer: { localValue, localAction, _ in
            self.send(toGlobalAction(localAction))
            localValue = toLocalValue(self.value)
            return []
        },
          environment: ()
        )
        localStore.viewCancellable = self.$value.sink { [weak localStore] newValue in
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

public func combine<Value, Action, Environment>(
    _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
    
    return { value, action, environment in
        //        var effects: [Effect] = []
        //        for reducer in reducers {
        //            let effect = reducer(&value, action)
        //            effects.append(effect)
        //        }
        let effects = reducers.flatMap{ $0(&value, action, environment) }
        return effects
        //        return { () -> Action? in
        //            for effect in effects {
        //                let action = effect()
        //                return action
        //            }
        //        }
    }
}

public func logging<Value, Action, Environment>(
  _ reducer: @escaping Reducer<Value, Action, Environment>,
  logger: @escaping (Environment) -> (String) -> Void
) -> Reducer<Value, Action, Environment> {
  return { value, action, environment in
    let effects = reducer(&value, action, environment)
    let newValue = value
    return [.fireAndForget {
      let print = logger(environment)
      print("Action: \(action)")
      print("Value:")
      var dumpedValue = ""
      dump(newValue, to: &dumpedValue)
      print(dumpedValue)
      print("---")
      }] + effects
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
    _ reducer: @escaping Reducer<LocalValue, LocalAction, LocalEnvironment>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>,
    environment: @escaping(GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    return { globalValue, globalAction, globalEnvironment in
        guard let localAction = globalAction[keyPath: action] else { return [] }
        let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
        
        return localEffects.map { localEffect in
            localEffect.map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
            .eraseToEffect()
            //            Effect { callback in
            //                // guard let localAction = localEffect() else { return nil }
            //                localEffect.run { localAction in
            //                    var globalAction = globalAction
            //                    globalAction[keyPath: action] = localAction
            //                    callback(globalAction)
            //                }
            //            }
        }
    }
}

extension Publisher where Failure == Never {
    public func eraseToEffect() -> Effect<Output> {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}

extension Effect {
    public static func fireAndForget(work: @escaping () -> Void) -> Effect {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }.eraseToEffect()
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
