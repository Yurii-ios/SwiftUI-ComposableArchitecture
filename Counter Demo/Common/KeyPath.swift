import Foundation

struct _KeyPath<Root, Value> {
    let get: (Root) -> Value
    let set: (inout Root, Value) -> Void
}

struct EnumKeyPath<Root, Value> {
    let embed: (Value) -> Root
    let extract: (Root) -> Value?
}
//\AppAction.counter // EnumKeyPath<AppAction, CounterAction>
