//
//  Stock.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/27/25.
//

import Foundation

struct Stock : Decodable {
    let company: String
    let description: String
    let initial_price: Double
    let price_2002: Double
    let price_2007: Double
    let symbol: String
    
    static var defaultStock: Stock {
        return Stock(company: "None", description: "None", initial_price: 0.0, price_2002: 0.0, price_2007: 0.0, symbol: "None")
    }
}
