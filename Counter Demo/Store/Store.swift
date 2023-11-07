//
//  Store.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 26/09/2022.
//

import Foundation

//final class Store<Value, Action>: ObservableObject {
//    let reducer: (inout Value, Action) -> Void
//    @Published private(set) var value: Value
//
//    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
//        self.value = initialValue
//        self.reducer = reducer
//    }
//
//    func send(_ action: Action) {
//        reducer(&value, action)
//    }
//}

// Store<AppState>
// self.state -> self.store.value
//(state: self.store.value) -> (store: self.store)

// exercises
func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { inoutA in
        let updatedA = f(inoutA)
        inoutA = updatedA
    }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var mutableA = a
        f(&mutableA)
        return mutableA
    }
}


func filterActions<Value, Action>(_ predicate: @escaping (Action) -> Bool)
-> (@escaping (inout Value, Action) -> Void) -> (inout Value, Action) -> Void {
    return { reducer in
        return { value, action in
            if predicate(action) {
                reducer(&value, action)
            }
        }
    }
}

struct UndoState<Value> {
    var value: Value
    var history: [Value]
    var undone: [Value]
    var canUndo: Bool { !self.history.isEmpty }
    var canRedo: Bool { !self.undone.isEmpty }}

enum UndoAction<Action> {
    case action(Action)
    case undo
    case redo
}

func undo<Value, Action>(_ reducer: @escaping (inout Value, Action) -> Void, limit: Int)
-> (inout UndoState<Value>, UndoAction<Action>) -> Void {
    return { undoState, undoAction in
        switch undoAction {
        case let .action(action):
            var currentValue = undoState.value
            reducer(&currentValue, action)
            undoState.history.append(currentValue)
            undoState.undone = []
            if undoState.history.count > limit {
                undoState.history.removeFirst()
            }
        case .undo:
            guard undoState.canUndo else { return }
            undoState.undone.append(undoState.value)
            undoState.value = undoState.history.removeLast()
        case .redo:
            guard undoState.canRedo else { return }
            undoState.history.append(undoState.value)
            undoState.value = undoState.undone.removeFirst()
        }
    }
}

//extension Store {
//    func view<LocalValue>(
//        /* what arguments are needed? */
//        _ f: @escaping (Value) -> LocalValue
//    ) -> Store<LocalValue, Action> {
//        return Store<LocalValue, Action>(
//            initialValue: f(self.value),
//            reducer { localValue, action in
//                self.reducer(&self.value, action)
//                localValue = f(self.value)
//            }
//        )
//    }
//}
