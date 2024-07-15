//
//  SignUpView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 19/5/24.
//

import SwiftUI

struct SignUpView: View {
    
    //variables dinamicas
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isPasswordVisible = false
    @State private var confirmPassword: String = ""
    @State private var isConfirmPasswordVisible = false
    @State private var passwordStrength: PasswordStrength = .weak

    
    //variables estaticas
    private var fecha_creacion: String {
           return FechaHelper.fechaEnString
       }
    
        var body: some View {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "person.badge.key.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Registrarse")
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
                
                
                HStack {
                    Image(systemName: "person.badge.shield.checkmark.fill")
                        .foregroundColor(.gray)
                    TextField("Nombre de usuario", text: $username)
                        .keyboardType(.default)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                
                VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.gray)
                                if isPasswordVisible {
                                    TextField("Contraseña", text: $password)
                                        .onChange(of: password) {
                                            passwordStrength = evaluatePasswordStrength(password)
                                        }
                                } else {
                                    SecureField("Contraseña", text: $password)
                                        .onChange(of: password) {
                                            passwordStrength = evaluatePasswordStrength(password)
                                        }
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
                    
                    
                    HStack {
                                       Image(systemName: "lock.fill")
                                           .foregroundColor(.gray)
                                       if isConfirmPasswordVisible {
                                           TextField("Confirmar Contraseña", text: $confirmPassword)
                                               .onChange(of: confirmPassword) {
                                                   passwordStrength = evaluatePasswordStrength(confirmPassword)
                                               }
                                       } else {
                                           SecureField("Confirmar Contraseña", text: $confirmPassword)
                                               .onChange(of: confirmPassword) {
                                                   passwordStrength = evaluatePasswordStrength(confirmPassword)
                                               }
                                       }
                                       Button(action: {
                                           isConfirmPasswordVisible.toggle()
                                       }) {
                                           Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                               .font(.system(size: 24))
                                               .foregroundColor(.gray)
                                       }
                                   }
                                   .padding()
                                   .background(Color(.systemGray6))
                                   .cornerRadius(10)
                                   .padding(.horizontal)
                    
                    
                    HStack {
                        Spacer()
                        HStack {
                            Text("Fuerza de la contraseña:")
                                .font(.subheadline)
                                .bold()
                            Text(passwordStrengthText())
                                .foregroundColor(passwordStrengthColor())
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.top, 2)
                    
                        }

                
                if let errorMessage = errorMessage {
                               Text(errorMessage)
                                   .foregroundColor(.red)
                                
                           }
                           
                           if let successMessage = successMessage {
                               Text(successMessage)
                                   .foregroundColor(.green)
                              
                           }
               
                
                Button(action: register) {
                    
                    Text("Registrarse")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Registrarse", displayMode: .inline)
        }
    
    
    func register() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
                self.errorMessage = "Por favor, complete todos los campos"
                return
            }
        
        guard password == confirmPassword else {
                    self.errorMessage = "Las contraseñas no coinciden"
                    return
                }
            
            guard let url = URL(string: "http://localhost:8080/api/Users") else {
                print("URL inválida")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        let userDetails = [
                            "email": email,
                            "username": username,
                            "password": password,
                            "confirmPassword": confirmPassword
                          ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: userDetails, options: [])
            } catch {
                print("Error codificando los detalles del usuario")
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print("Error: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let _ = data, let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        print("Respuesta inválida del servidor")
                    }
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.successMessage = "Te registraste exitosamente"
                        self.errorMessage = nil
                        
                        self.email = ""
                        self.password = ""
                        self.confirmPassword = ""
                        self.username = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error al registrarte"
                        self.successMessage = nil
                    }
                }
            }
            .resume()
        }
    
    
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
          if password.count >= 8 {
              return .strong
          } else if password.count >= 5 {
              return .medium
          } else {
              return .weak
          }
      }

      private func passwordStrengthText() -> String {
          switch passwordStrength {
          case .strong:
              return "Fuerte"
          case .medium:
              return "Media"
          case .weak:
              return "Débil"
          }
      }

      private func passwordStrengthColor() -> Color {
          switch passwordStrength {
          case .strong:
              return .green
          case .medium:
              return .yellow
          case .weak:
              return .red
          }
      }
    
    
    enum PasswordStrength {
        case strong
        case medium
        case weak
    }
      
    
}




struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
