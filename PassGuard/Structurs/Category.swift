//
//  Category.swift
//  PassGuard
//
//  Created by Bryan Mejia on 29/5/24.
//

import Foundation



struct Category: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case id = "categoryId"
        case name = "categoryName"
        case description
    }
}

struct CategoryResponse: Codable {
    var statusCode: Int
    var success: Bool
    var message: String
    var data: [Category]
}

struct CreateCategoryModel: Codable {
    let categoryName: String
    let description: String
    let userId: Int
}

struct DeleteCategoryResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: String?
}


struct APIResponse<T: Codable>: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: T
}
