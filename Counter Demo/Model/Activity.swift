//
//  Activity.swift
//  Counter Demo
//
//  Created by Yurii Sameliuk on 25/09/2022.
//

import Foundation

struct Activity: Equatable {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType: Equatable {
        case addedFavoritePrime(Int)
        case removeFavoritePrime(Int)
    }
}
