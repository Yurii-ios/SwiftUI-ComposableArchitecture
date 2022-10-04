//
//  Logging.swift
//  Counter Demo
//
//  Created by Yurii.Semeliuk on 04/10/2022.
//

import Foundation

func logging(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
  ) -> (inout AppState, AppAction) -> Void {
    return { value, action in
      reducer(&value, action)
      print("Action: \(action)")
      print("State:")
      dump(value)
      print("---")
    }
  }
