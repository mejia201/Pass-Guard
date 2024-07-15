//
//  HomeView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI



struct HomeView: View {
    
    @State private var categoriesCount = 0
    @State private var platformsCount = 0
    @State private var passwordsCount = 0
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingEditProfile = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                    if let user = userData.user {
                        Text("Bienvenido, \(user.username)")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Te presentamos un resumen de toda tu información existente en nuestra aplicación.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    CardView(
                        image: "folder.fill",
                        title: "Categorías",
                        subtitle: "\(categoriesCount) Categorías agregadas",
                        iconColor: .blue
                    )
                    
                    CardView(
                        image: "platter.2.filled.ipad",
                        title: "Plataformas",
                        subtitle: "\(platformsCount) Plataformas agregadas",
                        iconColor: .blue
                    )
                    
                    CardView(
                        image: "key.fill",
                        title: "Contraseñas",
                        subtitle: "\(passwordsCount) Contraseñas agregadas",
                        iconColor: .blue
                    )
                }
                .padding()
            }
            .navigationBarTitle("Inicio", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isShowingEditProfile.toggle()
            }) {
                Image(systemName: "person.crop.circle")
                    .imageScale(.large)
                    .font(.system(size: 24))
            })
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileView()
                    .environmentObject(userData)
            }
            .onAppear {
                if let userId = userData.user?.id {
                    fetchDashboardData(userId: userId) { result in
                        switch result {
                        case .success(let dashboardData):
                            categoriesCount = dashboardData.categoriesCount
                            platformsCount = dashboardData.platformsCount
                            passwordsCount = dashboardData.passwordsCount
                        case .failure(let error):
                            print("Error fetching dashboard data: \(error)")
                        }
                    }
                }
            }
        }
    }
}


struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible = false
    @EnvironmentObject var userData: UserData
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isDeleteAlertPresented = false


    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Información Personal")) {
                        TextField("Usuario", text: $name)
                        TextField("Correo Electrónico", text: $email)
                            .keyboardType(.emailAddress)
                        HStack {
                            if isPasswordVisible {
                                TextField("Contraseña", text: $password)
                            } else {
                                SecureField("Contraseña", text: $password)
                            }
                            Spacer()
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 10)
                        }
                    }

                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        HStack {
                            Button(action: updateProfile) {
                                Text("Actualizar")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.yellow)
                                    .cornerRadius(8)
                            }
                            .disabled(isLoading)
                            
                        }
                    }
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
                
                
                
                Button(action: {
                isDeleteAlertPresented = true
                }) {
                    HStack {
                        Text("Eliminar Cuenta")
                            .foregroundColor(.white)
                        }
                            .padding()
                            .frame(maxWidth: 300)
                            .background(Color.red)
                            .cornerRadius(8)
                        }
                        .padding(.top)
                        .alert(isPresented: $isDeleteAlertPresented) {
                Alert(
                title: Text("Confirmar Eliminación"),
                message: Text("¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer."),
                primaryButton: .destructive(Text("Eliminar")) {
                            deleteAccount()
                },
                    secondaryButton: .cancel()
                    )
                }
                
            }
            .navigationBarTitle("Perfil", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                userData.logout()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                    .imageScale(.large)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    
            })
        }
        .onAppear {
            if let user = userData.user {
                self.name = user.username
                self.email = user.email
                self.password = user.password
            }
        }
    }

    func updateProfile() {
        guard let user = userData.user else {
            errorMessage = "Error: Usuario no encontrado"
            return
        }

        guard let updateProfileURL = URL(string: "http://localhost:8080/api/Users/\(user.id)") else {
            errorMessage = "URL inválida"
            return
        }

        var request = URLRequest(url: updateProfileURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let userDetails: [String: Any?] = [
            "userId": user.id,
            "username": name.isEmpty ? nil : name,
            "email": email.isEmpty ? nil : email,
            "password": password.isEmpty ? nil : password
        ]

        let filteredUserDetails = userDetails.compactMapValues { $0 }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredUserDetails, options: [])
        } catch {
            errorMessage = "Error codificando los detalles del usuario"
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Respuesta inválida del servidor"
                    return
                }

                if httpResponse.statusCode == 200 {
                    self.successMessage = "Perfil actualizado exitosamente"
                    self.errorMessage = nil

                    // Actualizar datos del usuario en el entorno
                    if !self.name.isEmpty {
                        userData.user?.username = self.name
                    }
                    if !self.email.isEmpty {
                        userData.user?.email = self.email
                    }
                    if !self.password.isEmpty {
                        userData.user?.password = self.password
                    }

                    // Cerrar la vista de edición
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    if let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMsg = responseData["message"] as? String {
                        self.errorMessage = "Error: \(errorMsg)"
                    } else {
                        self.errorMessage = "Error al actualizar el perfil. Código de estado: \(httpResponse.statusCode)"
                    }
                    self.successMessage = nil
                }
            }
        }
        .resume()
    }


    
    
    func deleteAccount() {
        guard let user = userData.user else {
            errorMessage = "Error: Usuario no encontrado"
            return
        }

        guard let deleteAccountURL = URL(string: "http://localhost:8080/api/Users/\(user.id)") else {
            errorMessage = "URL inválida"
            return
        }

        var request = URLRequest(url: deleteAccountURL)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        isLoading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    print("Error: \(error.localizedDescription)") // Agregado para más detalles de depuración
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Respuesta inválida del servidor"
                    print("Respuesta inválida del servidor") // Agregado para más detalles de depuración
                    return
                }

                if httpResponse.statusCode == 200 {
                    self.successMessage = "Cuenta eliminada exitosamente"
                    self.errorMessage = nil

                    userData.logout()
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    if let data = data,
                       let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let errorMessage = responseDict["message"] as? String {
                        self.errorMessage = "Error: \(errorMessage)"
                        print("Error del servidor: \(errorMessage)") // Agregado para más detalles de depuración
                    } else {
                        self.errorMessage = "Error al eliminar la cuenta. Código de estado: \(httpResponse.statusCode)"
                        print("Error al eliminar la cuenta. Código de estado: \(httpResponse.statusCode)") // Agregado para más detalles de depuración
                    }
                    self.successMessage = nil
                }
            }
        }
        .resume()
    }

    
    
}



struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
            .environmentObject(UserData())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserData())
    }
}
