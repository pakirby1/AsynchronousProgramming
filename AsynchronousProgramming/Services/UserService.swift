//
//  UserService.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 1/24/25.
//

import Foundation

class UserService {
    func getUsers() -> [User] {
        return [
            buildUser(first: "Phil", last: "Kirby"),
            buildUser(first: "Quintella", last: "Kirby"),
            buildUser(first: "Kimberly", last: "Kirby")
        ]
    }
    
    private func buildUser(first: String, last: String) -> User {
        return User(first: first, last: last, dob: Date.now)
    }
}
