import ComposableArchitecture

let store = Store<Int, Void>(initialValue: 0, reducer: { count, _ in count += 1 })

store.send(())
store.send(())
store.send(())
store.send(())
store.send(())

store.value // 5

let newStore = store.view { $0 }

newStore.value // 5

newStore.send(())
newStore.send(())
newStore.send(())
newStore.value // 8

store.send(())
store.send(())
store.send(())

newStore.value // 8
store.value // 11

var xs = [1, 2, 3]
var ys = xs.map { $0 }
ys.append(4)

xs // [1, 2, 3]
ys // [1, 2, 3, 4]
