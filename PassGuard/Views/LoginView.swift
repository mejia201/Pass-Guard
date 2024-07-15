//
//  LoginView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 19/5/24.
//

import SwiftUI


struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    @State private var isLoggedIn = false
    @State private var isPasswordVisible = false
    
    @StateObject private var userData = UserData()
    
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Iniciar Sesión")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            
            
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                TextField("Correo Electrónico", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    if isPasswordVisible {
                        TextField("Contraseña", text: $password)
                    } else {
                        SecureField("Contraseña", text: $password)
                    }
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: login) {
                Text("Iniciar Sesión")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
            
           
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Ocurrió un error"), dismissButton: .default(Text("OK")))
        }
        .padding()
        .navigationBarTitle("Iniciar Sesión", displayMode: .inline)
        .fullScreenCover(isPresented: $isLoggedIn) {
            PrincipalView().environmentObject(userData)
        }
    }
    
    
    
    
    
    func login() {
            guard !email.isEmpty, !password.isEmpty else {
                self.errorMessage = "Por favor, complete todos los campos"
                return
            }

            guard let url = URL(string: "http://localhost:8080/api/Users/login") else {
                print("URL inválida")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let loginDetails = ["email": email, "password": password]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: loginDetails, options: [])
            } catch {
                print("Error codificando los detalles del inicio de sesión")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No se recibieron datos del servidor")
                    return
                }

                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)

                    if loginResponse.success {
                        if let userData = loginResponse.data {
                            print("Inicio de sesión exitoso. Usuario: \(userData.username)")
                            DispatchQueue.main.async {
                                self.userData.user = userData
                                self.isLoggedIn = true
                                print(userData)
                              
                            }
                        } else {
                            print("No se recibieron datos del usuario del servidor")
                        }
                    } else {
                        print("Inicio de sesión fallido. Mensaje: \(loginResponse.message)")
                        DispatchQueue.main.async {
                            self.errorMessage = "Credenciales incorrectas"
                            self.showErrorAlert = true
                        }
                    }
                } catch {
                    print("Error decodificando la respuesta del servidor:", error)
                    DispatchQueue.main.async {
                        self.errorMessage = "Ocurrió un error al decodificar los datos del servidor"
                        self.showErrorAlert = true
                    }
                }
            }.resume()
        
        
        
        
    }
    
        
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserData())
    }
}

