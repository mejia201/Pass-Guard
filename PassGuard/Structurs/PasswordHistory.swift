//
//  PasswordHistory.swift
//  PassGuard
//
//  Created by Bryan Mejia on 2/6/24.
//

import Foundation

// Estructura para representar la respuesta JSON
struct PasswordHistoryResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: [PasswordHistoryData]
}

struct PasswordHistoryData: Codable {
    let historyId: Int
    let platformName: String
    let oldPassword: String
    let changeDate: String
}

struct User2: Codable {
    let userId: Int
    let email: String
    let password: String
    let username: String
    let categories: [Category3]
    let platforms: [Platform3]
    let passwords: [Password3]
}

struct Category3: Codable {
    let categoryId: Int
    let categoryName: String
    let description: String
}

struct Platform3: Codable {
    let platform_id: Int
    let description: String
    let platform_name: String
    let url: String
}

struct Password3: Codable {
    let passwordId: Int
    let platform: Platform3
    let category: Category3
    let platformUsername: String
    let password: String
}



struct DeleteHistoryResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: String?
}
