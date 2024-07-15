//
//  Items.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI

let backgroundColor = Color.init(white: 0.92)


enum Tab: Int, Identifiable, CaseIterable, Comparable {
    static func < (lhs: Tab, rhs: Tab) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    case home, categories, platforms, passwords, history
    
    internal var id: Int { rawValue }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .categories:
            return "note"
        case .platforms:
            return "macbook.and.iphone"
        case .passwords:
            return "key.fill"
            
        case .history:
            return "clock.fill"
            
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Inicio"
        case .categories:
            return "Categorias"
        case .platforms:
            return "Plataformas"
        case .passwords:
            return "Contraseñas"
        case .history:
            return "Historial"
            
        }
    }
    
    var color: Color {
        switch self {
        case .home:
            return .indigo
        case .categories:
            return .green
        case .platforms:
            return .orange
        case .passwords:
            return .blue
        case .history:
            return .teal

        }
        
    }
}
