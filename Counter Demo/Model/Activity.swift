//
//  Activity.swift
//  Counter Demo
//
//  Created by Yurii Sameliuk on 25/09/2022.
//

import Foundation

struct Activity {
    let timestamp: Date
    let type: ActivityType
    
    enum ActivityType {
        case addedFavoritePrime(Int)
        case removeFavoritePrime(Int)
    }
}
