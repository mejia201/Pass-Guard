//
//  HCard.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI

struct HCard: View {
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoria 1")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("descripcion")
                    .font(.body)
            }
            Divider()
    
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: 110)
        .foregroundColor(.white)
        .background(Color.green)
        .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

struct HCard_Previews: PreviewProvider {
    static var previews: some View {
        HCard()
    }
}

