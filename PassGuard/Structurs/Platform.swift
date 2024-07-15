//
//  Platform.swift
//  PassGuard
//
//  Created by Bryan Mejia on 29/5/24.
//

import Foundation



struct Platform: Identifiable, Codable {
    let id: Int
    let description: String?
    let platform_name: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case id = "platform_id"
        case platform_name = "platform_name"
        case description
        case url
    }
}

struct PlatformResponse: Codable {
    var statusCode: Int
    var success: Bool
    var message: String
    var data: [Platform]
}

struct CreatePlatformModel: Codable {
    let platform_name: String
    let description: String
    let url: String
    let userId: Int
}


struct DeletePlatformResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: String?
}


struct APIResponsePlatform<T: Codable>: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: T
}
