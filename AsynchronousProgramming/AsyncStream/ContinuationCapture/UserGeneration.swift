//
//  UserGeneration.swift
//  AsynchronousProgramming
//
//  Created by Phil Kirby on 2/13/25.
//

import Foundation
import SwiftUI

struct UserGenerationView : View {
    @State var viewModel: UserGeneratorViewModel = UserGeneratorViewModel()
    let defaultUser: JSONPlaceholderUser = .init(id: -1, name: "Empty", username: "empty", email: "none", address: .init(street: "none", suite: "none", city: "none", zipcode: "none", geo: .init(lat: "nont", lng: "none")), phone: "none", website: "none", company: .init(name: "none", catchPhrase: "none", bs: "none"))
    
    var body: some View {
        VStack {
            HStack {
                Button("Start") {
                    viewModel.start()
                }
                Button("Stop") {
                    viewModel.stop()
                }
            }
            
            UserGenerationRowView(user: viewModel.currentUser ?? defaultUser)
            
            Spacer()
            List {
                ForEach(viewModel.users, id: \.id) { user in
                    UserGenerationRowView(user: user)
                }
            }
        }
    }
}

struct UserGenerationRowView : View {
    let user: JSONPlaceholderUser
    
    var body: some View {
        VStack {
            HStack {
                Text(user.name)
                Spacer()
                Text("(\(user.username))")
            }
            
            HStack {
                Text(user.email)
                Spacer()
            }
            
        }
    }
}

@Observable
@MainActor
class UserGeneratorViewModel : @preconcurrency TaskCancellable {
    var task: Task<(), Never>?
    
    let service: UserGeneratorService = UserGeneratorService()
    var currentUser: JSONPlaceholderUser?
    var users: [JSONPlaceholderUser] = []
    
    func start() {
        self.task = Task {
            for await jsonUser in service.start() {
                currentUser = jsonUser
                users.append(jsonUser)
            }
        }
    }
    
    func stop() {
        print("ItemGeneratorViewModel.stop() called")
        // cancel and set task to nil
        cancelTask(label: "ItemGeneratorViewModel.task")
        
//        srv.stopEventGeneration()
        print("ItemGeneratorViewModel.stop() ended")
    }
}

class UserGeneratorService {
    let url: String = "https://jsonplaceholder.typicode.com/users"
    var continuation: AsyncStream<JSONPlaceholderUser>.Continuation? = nil
    
    // Returns a stream of JSONPlaceholderUser
    func start() -> AsyncStream<JSONPlaceholderUser> {
        return AsyncStream<JSONPlaceholderUser> { @Sendable continuation in
            self.continuation = continuation
            
//            continuation.onTermination { @Sendable termination in
//                print("finished")
//            }
            
            Task {
                let endpoint: EndpointProvider = MyEndpoint(url)
                
                do {
                    let jsonUsers = try await asyncRequest(endpoint: endpoint, responseModel: [JSONPlaceholderUser].self)
                    for jsonUser in jsonUsers {
                        try? await Task.sleep(for: .milliseconds(2000))
                        continuation.yield(jsonUser)
                    }
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func stop() async {
        guard let continuation = self.continuation else { return }
        continuation.finish()
    }
}

extension UserGeneratorService : APIInterface {
    func asyncRequest<T>(endpoint: any EndpointProvider, responseModel: T.Type) async throws -> T where T : Decodable {
        // Get and serialize the JSON Users
        let url = URL(string: url)!

        /// Use URLSession to fetch the data asynchronously.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        /// Decode the JSON response into the PostResponse struct.
        let jsonUsers: [JSONPlaceholderUser] = try JSONDecoder().decode([JSONPlaceholderUser].self, from: data)
        
        return jsonUsers as! T
    }
}

struct JSONPlaceholderUser: Codable {
    struct Address: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo
    }
    
    struct Geo: Codable {
        let lat: String
        let lng: String
    }
    
    struct Company: Codable {
        let name: String
        let catchPhrase: String
        let bs: String
    }
    
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
}

enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

protocol EndpointProvider {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var token: String { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: Any]? { get }
    var mockFile: String? { get }
}

protocol APIInterface {
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T
}

struct MyEndpoint: EndpointProvider {
    var scheme: String
    var baseURL: String
    var path: String
    var method: RequestMethod
    var token: String
    var queryItems: [URLQueryItem]?
    var body: [String : Any]?
    var mockFile: String?
    
    init(_ url: String) {
        scheme = ""
        baseURL = url
        path = ""
        method = .get
        token = ""
        queryItems = nil
        body = nil
        mockFile = nil
    }
}
