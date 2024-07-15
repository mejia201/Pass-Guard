//
//  ContentView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 19/5/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Bienvenido a PassGuard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Tu gestor de contraseñas seguro y fácil de usar.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
        
                NavigationLink(destination: LoginView()) {
                    HStack {
                            Image(systemName: "person.fill")
                                Text("Iniciar Sesión")
                                .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            }
                
                NavigationLink(destination: SignUpView()) {
                    HStack {
                            Image(systemName: "person.text.rectangle")
                                Text("Registrarse")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .frame(width: 200, height: 50)
                            .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                                    )
                             }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserData())
    }
}
