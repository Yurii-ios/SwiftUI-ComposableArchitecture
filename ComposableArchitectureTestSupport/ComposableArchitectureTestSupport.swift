import ComposableArchitecture
import XCTest

public enum StepType {
    case send
    case receive
}

public struct Step<Value, Action> {
    let type: StepType
    let action: Action
    let file: StaticString
    let line: UInt
    let update: (inout Value) -> Void
    
   public init(
        type: StepType,
        _ action: Action,
        file: StaticString = #file,
        line: UInt = #line,
        _ update: @escaping (inout Value) -> Void = { _ in }) {
            self.action = action
            self.update = update
            self.file = file
            self.line = line
        }
}

public func assert<Value: Equatable, Action: Equatable, Environment>(
    initialValue: Value,
    reducer: Reducer<Value, Action, Environment>,
    environment: Environment,
    steps: Step<Value, Action> ...,
    file: StaticString = #file,
    line: UInt = #line
) {
    var state = initialValue
    steps.forEach { step in
        var expected = state
        var effects: [Effect<Action>] = []
        switch step.type {
        case .send:
            if !effects.isEmpty {
                XCTFail("Action sent before handling \(effects.count) pending effect(s)", file: step.file, line: step.line)
            }
            effects.append(contentsOf: reducer(&state, step.action, environment))
        case .receive:
            guard !effects.isEmpty else {
                XCTFail("No pending effects to receive from", file: step.file, line: step.line)
                break
            }
            let effect = effects.removeFirst()
            var action: Action!
            let receivedCompletion = XCTestExpectation(description: "receivedCompletion")
           _ = effect.sink { _ in
                receivedCompletion.fulfill()
            } receiveValue: { action = $0 }
            if XCTWaiter.wait(for: [receivedCompletion], timeout: 0.01) != .completed {
                XCTFail("Timed out waiting for the effect to complete",
                        file: step.file, line: step.line)
            }
            XCTAssertEqual(action, step.action, file: step.file, line: step.line)
            effects.append(contentsOf: reducer(&state, action, environment))
        }
        step.update(&expected)
        XCTAssertEqual(state, expected, file: step.file, line: step.line)
        
        if !effects.isEmpty {
            XCTFail("Assertion failed to handle \(effects.count) pending effect(s)", file: step.file, line: step.line)
        }
    }
}
