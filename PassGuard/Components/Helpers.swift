//
//  Helpers.swift
//  PassGuard
//
//  Created by Bryan Mejia on 26/5/24.
//

import Foundation


class FechaHelper {
    static var fechaEnString: String {
        let hoy = Date()
        let formateador = DateFormatter()
        formateador.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formateador.string(from: hoy)
    }
}
