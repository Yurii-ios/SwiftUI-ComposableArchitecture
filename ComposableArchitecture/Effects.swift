//
//  Effects.swift
//  ComposableArchitecture
//
//  Created by Yurii.Semeliuk on 14/10/2022.
//

import Foundation

extension Effect where A == (Data?, URLResponse?, Error?) {
  public func decode<B: Decodable>(as type: B.Type) -> Effect<B?> {
    return self.map { data, _, _ in
      data
        .flatMap { try? JSONDecoder().decode(B.self, from: $0) }
    }
  }
}

extension Effect {
  public func receive(on queue: DispatchQueue) -> Effect {
    return Effect { callback in
      self.run { a in
        queue.async { callback(a) }
      }
    }
  }
}
