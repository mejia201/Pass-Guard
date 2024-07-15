//
//  CardView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 23/5/24.
//

import SwiftUI

struct CardView: View {
    let image: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: image)
              
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(iconColor)
                .cornerRadius(10)
                .padding(.bottom, 5)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 5)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(image: "folder.fill", title: "Categorías", subtitle: "3 Categorías creadas", iconColor: Color.blue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

