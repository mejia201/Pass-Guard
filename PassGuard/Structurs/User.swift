//
//  User.swift
//  PassGuard
//
//  Created by Bryan Mejia on 27/5/24.
//

import Foundation



struct UpdateUserModel: Codable {
    let userId: Int
    let creationDate: Date
    let email: String
    let password: String
    let username: String
}

struct LoginResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: User?

    struct User: Codable {
        var id: Int
        var email: String
        var username: String
        var password: String
    }
}


class UserData: ObservableObject {
    @Published var user: LoginResponse.User?
    
    func logout() {
            self.user = nil
        }
    
}



