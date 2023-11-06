import Combine
import Dispatch

public struct Effect<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
        return Effect<B> { callback in self.run { a in callback(f(a)) } }
    }
}

let anIntInTwoSeconds = Effect<Int> { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        callback(42)
    }
}

anIntInTwoSeconds.run { int in print(int) }
// 42

let squared = anIntInTwoSeconds.map { $0 * $0 }
// Effect<Int>

//Publisher.init
//AnyPublisher.init(publisher: Publisher)

var count = 0
let iterator = AnyIterator<Int>.init {
    count += 1
    return count
}
// AnyIterator<Int>

Array(iterator.prefix(10))
// [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

//Future.init(attemptToFulfill: (@escaping (Result<_, _>) -> Void) -> Void)

Future<Int, Never> { callback in
    callback(.success(42))
}

let aFutureInt = Deferred {
    Future<Int, Never> { callback in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Hello from future")
            callback(.success(42))
        }
    }
}

//AnySubscriber.init(
//  receiveSubscription: ((Subscription) -> Void)?,
//  receiveValue: ((_) -> Subscribers.Demand)?,
//  receiveCompletion: ((Subscribers.Completion<_>) -> Void)?
//)

aFutureInt.subscribe(
    AnySubscriber<Int, Never>(
        receiveSubscription: { subscription in
            print("subscription")
            subscription.request(.unlimited)
        },
        receiveValue: { value in
            print("value", value)
            return .unlimited
        },
        receiveCompletion: { completion in
            print("completion", completion)
        })
)

let cancellable = aFutureInt.sink { int in
    print(int)
}

let passthrough = PassthroughSubject<Int, Never>()
let currentValue = CurrentValueSubject<Int, Never>(1)

let c1 = passthrough.sink { x in print("passthrough", x) }
let c2 = currentValue.sink { x in print("currentValue", x) }

passthrough.send(42)
currentValue.send(1729)
passthrough.send(42)
currentValue.send(1729)
// passthrough 42
// currentValue 1729
// passthrough 42
// currentValue 1729

//extension ViewBuilder {
//    public static func buildBlock<each C: View>(
//        c: repeat each c
//    ) -> TupleView<(repeat each C)> {
//        return TupleView( (repeat each c))
//    }
//}
