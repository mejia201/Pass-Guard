//
//  Dashboard.swift
//  PassGuard
//
//  Created by Bryan Mejia on 27/5/24.
//

import Foundation

struct DashboardResponse: Codable {
    let statusCode: Int
    let success: Bool
    let message: String
    let data: DashboardData?
}

struct DashboardData: Codable {
    let categoriesCount: Int
    let platformsCount: Int
    let passwordsCount: Int
}


func fetchDashboardData(userId: Int, completion: @escaping (Result<DashboardData, Error>) -> Void) {
    guard var urlComponents = URLComponents(string: "http://localhost:8080/api/dashboard") else {
        print("URL inválida")
        return
    }
    
    urlComponents.queryItems = [
        URLQueryItem(name: "idUsuario", value: String(userId))
    ]
    
    guard let url = urlComponents.url else {
        print("URL inválida con parámetros")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("No se recibieron datos del servidor")
            return
        }
        
        do {
            let dashboardResponse = try JSONDecoder().decode(DashboardResponse.self, from: data)
            if dashboardResponse.success, let dashboardData = dashboardResponse.data {
                completion(.success(dashboardData))
            } else {
                print("Error en la respuesta del servidor: \(dashboardResponse.message)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error en la respuesta del servidor"])))
            }
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
