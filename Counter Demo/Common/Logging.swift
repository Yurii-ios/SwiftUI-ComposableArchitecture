//
//  Logging.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 04/10/2022.
//

import Foundation

func logging<Value, Action>(
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
