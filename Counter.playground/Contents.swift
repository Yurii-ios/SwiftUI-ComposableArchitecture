import ComposableArchitecture
import Favoriteprimes
import PrimeModel
import Counter
import SwiftUI
import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: CounterView(
    store: Store<CounterViewState, CounterViewAction>(
      initialValue: (0, []),
      reducer: counterViewReducer
    )
  )
  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
)

//PlaygroundPage.current.liveView = UIHostingController(
//  rootView: FavoriteView(
//    store: Store<[Int], FavoritePrimeAction>(
//      initialValue: [2,3,4,5],
//      reducer: favoritePrimesReducer
//    )
//  )
//  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//)

//PlaygroundPage.current.liveView = UIHostingController(
//  rootView: PrimeSheetView(
//    store: Store<PrimeModalState, PrimeModalAction>(
//      initialValue: (1, [2,0]),
//      reducer: primeModalReducer
//    )
//  )
//  .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//)

func compute(_ x: Int) -> Int {
  let computation = x * x + 1
  print("Computed \(computation)")
  return computation
}

func computeAndPrint(_ x: Int) -> (Int, [String]) {
  let computation = x * x + 1
  return (computation, ["Computed \(computation)"])
}

//import ComposableArchitecture
//
//let store = Store<Int, Void>(initialValue: 0, reducer: { count, _ in count += 1 })
//
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//store.send(())
//
//store.value // 5
//
//let newStore = store.view { $0 }
//
//newStore.value // 5
//
//newStore.send(())
//newStore.send(())
//newStore.send(())
//newStore.value // 8
//
//store.send(())
//store.send(())
//store.send(())
//
//newStore.value // 8
//store.value // 11
//
//var xs = [1, 2, 3]
//var ys = xs.map { $0 }
//ys.append(4)
//
//xs // [1, 2, 3]
//ys // [1, 2, 3, 4]
