//
//  User.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/24/25.
//

import Foundation

struct User {
    let id = UUID()
    let details: UserDetails
    
    init(first: String, last: String, dob: Date = Date.now) {
        details = UserDetails(firstName: first, lastName: last, dob: Date.now)
    }
}

struct UserDetails {
    let firstName: String
    let lastName: String
    let dob: Date
}
