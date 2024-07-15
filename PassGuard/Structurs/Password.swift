//
//  Password.swift
//  PassGuard
//
//  Created by Bryan Mejia on 31/5/24.
//

import Foundation

struct Platform2: Codable, Identifiable {
    let id: Int
    let description: String
    let platform_name: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id = "platform_id"
        case description
        case platform_name
        case url
    }
}

struct Category2: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name = "categoryName"
        case description
    }
}



struct Password: Identifiable, Codable {
    let id: Int
    let platform: Platform2
    let category: Category2
    let platformUsername: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case id = "passwordId"
        case platform = "platformId"
        case category = "categoryId"
        case platformUsername = "platformUsername"
        case password = "password"
    }
}

struct PasswordData: Codable {
    let passwordId: Int
    let platform: Platform2
    let category: Category2
    let platformUsername: String
    let password: String
}

struct PasswordResponse: Codable {
    var statusCode: Int
    var success: Bool
    var message: String
    var data: [PasswordData]
}


struct PasswordResponseData2: Codable {
    let passwordId: Int
    let platform: Platform2
    let category: Category2
    let platformUsername: String
    let password: String
}

struct PasswordResponse2: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: PasswordResponseData2
}


struct CreatePasswordModel: Codable {
    let platformUsername: String
    let password: String
    let platformId: Int
    let categoryId: Int
    let userId: Int
    

}


struct CreatePasswordModelAdd: Codable {
    let platformUsername: String
    let password: String
    let confirmPassword: String
    let platformId: Int
    let categoryId: Int
    let userId: Int
    

}

struct DeletePasswordResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: String?
}

struct APIResponsePassword<T: Codable>: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: T
}



struct PasswordEntry: Identifiable, Hashable {
    let id: Int
    let platform: String
    let category: String
    let username: String
    let password: String
    let platformId: Int?
    let categoryId: Int?
}

