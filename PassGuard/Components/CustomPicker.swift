//
//  CustomPicker.swift
//  PassGuard
//
//  Created by Bryan Mejia on 25/5/24.
//

import SwiftUI

struct CustomPicker: View {
    @Binding var selection: String
    let title: String
    let options: [String]
    let placeholder: String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                }
            }
        } label: {
            HStack {
                Text(title)
                Text(selection.isEmpty ? placeholder : selection)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .padding(.horizontal)
            .background(Color.blue)
            .cornerRadius(10)
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 10)
        }
    }
}

struct CustomPicker_Previews: PreviewProvider {
    @State static var previewSelection = "Seleccione una opción"

    static var previews: some View {
        CustomPicker(selection: $previewSelection, title: "Seleccione", options: ["Opción 1", "Opción 2", "Opción 3"], placeholder: "Seleccione una opción")
    }
}
