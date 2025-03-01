//
//  DataService.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/27/25.
//

import Foundation

protocol DataService {
    func getStocks() async -> [Stock]
}

class JSONDataService : DataService {
    private func loadJSON(fileName: String, directoryPath: String) -> String {
//        if let path = Bundle.main.path(forResource: fileName,
//                                       ofType: "json",
//                                       inDirectory: directoryPath)
            
        if let path = Bundle.main.path(forResource: "stocks", ofType: "json")
        {
            print("path: \(path)")
            
            do {
                let json = try String(contentsOfFile: path)
                return json
            } catch {
                print("error reading from \(path)")
                return ""
            }
        } else {
            print("file '\(fileName).json' not found in \(directoryPath)")
        }
        
        return ""
    }

    private func deserialize<T: Decodable>(jsonString: String) -> T {
        print(jsonString)
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        var ret: T? = nil   // FIXME: How do I NOT use optionals???

        do {
            ret = try decoder.decode(T.self, from: jsonData)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
    
        return ret! // FIXME: How do I NOT use optionals???
    }

    func getStocks() async -> [Stock] {
        // Serialize to [Stock]
        let stocks: [Stock] = deserialize(jsonString: loadJSON(fileName: "stocks", directoryPath: "Resources"))
        
        return stocks
    }
}

class CoreDataService : DataService {
    func getStocks() async -> [Stock] {
        return []
    }
}
