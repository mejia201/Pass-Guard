//
//  PasswordsView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI
import Foundation

struct PasswordsView: View {
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAddingItem = false
    @State private var isEditingItem = false
    @State private var newPlatformUsername = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var confirmnewPassword = ""
    
    @State private var selectedPlatformId: Int? = nil
    @State private var selectedCategoryId: Int? = nil
    @State private var passwordStrength: PasswordStrength = .weak



    @State private var editItemPlatformUsername = ""
    @State private var editItemPassword = ""
    @State private var passwords = [PasswordEntry]()

    @State private var pass: [Password] = []
    @State private var platforms: [Platform] = []
    @State private var categories: [Category] = []
    
    @State private var selectedItemIndex: Int?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isDeleteAlertPresented = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var isConfirmNewPasswordVisible = false

    @State private var isEditPasswordVisible = false
    @State private var editItemPasswordDidChange = false
    @State private var isInitialLoad = true


    var body: some View {
          NavigationView {
              ZStack {
                  Color.white
                      .edgesIgnoringSafeArea(.all)

                  if isLoading {
                      ProgressView()
                  } else if passwords.isEmpty {
                      Text("No hay contraseñas disponibles")
                          .font(.headline)
                          .foregroundColor(.gray)
                  } else {
                      List {
                          ForEach(passwords) { password in
                              HStack {
                                  Image(systemName: "key.fill")
                                      .foregroundColor(.blue)
                                  Text(password.username)
                                      .font(.headline)
                                  Spacer()
                                  Button(action: {
                                      if let index = passwords.firstIndex(where: { $0.id == password.id }) {
                                          selectedItemIndex = index
                                          editItemPlatformUsername = password.username
                                          editItemPassword = password.password
                                       
                                          selectedPlatformId = password.platformId
                                          selectedCategoryId = password.categoryId

                                          isEditingItem.toggle()
                                      }
                                  }) {
                                      Image(systemName: "pencil")
                                          .font(.system(size: 20))
                                          .foregroundColor(.yellow)
                                  }
                                  .buttonStyle(BorderlessButtonStyle())

                                  Button(action: {
                                      isDeleteAlertPresented = true
                                  }) {
                                      Image(systemName: "trash.fill")
                                          .font(.system(size: 20))
                                          .foregroundColor(.red)
                                  }
                                  .alert(isPresented: $isDeleteAlertPresented) {
                                      Alert(
                                          title: Text("Confirmar Eliminación"),
                                          message: Text("¿Estás seguro de que deseas eliminar la contraseña? Esta acción no se puede deshacer."),
                                          primaryButton: .destructive(Text("Eliminar")) {
                                              deletePassword(password.id)
                                          },
                                          secondaryButton: .cancel()
                                      )
                                  }
                              }
                              .listRowBackground(Color.white)
                          }
                      }
                      .background(Color.white)
                      .scrollContentBackground(.hidden)
                  }
              }
              .navigationBarTitle("Contraseñas", displayMode: .inline)
              .navigationBarItems(trailing:
                  Button(action: {
                      self.isAddingItem.toggle()
                  }) {
                      Image(systemName: "plus")
                  }
              )
              .sheet(isPresented: $isAddingItem) {
                  addPasswordView
              }
              .sheet(isPresented: $isEditingItem) {
                         editPasswordView
                     }
              .onAppear(perform: {
                  loadPasswords()
                  loadPlatformsAndCategories()
              })
          }
      }
    
    
    private var addPasswordView: some View {
         VStack {
             Text("Agregar nueva Contraseña")
                 .font(.title2)
                 .bold()
                 .padding()

             VStack(alignment: .leading, spacing: 16) {
                 
                 HStack {
                     Image(systemName: "network")
                         .font(.system(size: 24))
                         .foregroundColor(.blue)
                     Picker("Selecciona una plataforma", selection: $selectedPlatformId) {
                         ForEach(platforms) { platform in
                             Text(platform.platform_name)
                                 .font(.system(size: 16))
                                 .tag(platform.id as Int?)
                                 .multilineTextAlignment(.center)
                         }
                     }
                         .pickerStyle(MenuPickerStyle())
                         .frame(maxWidth: .infinity)
                         .frame(height: 20)
                         .padding()
                         .background(Color(.systemGray6))
                         .cornerRadius(10)
                         .font(.system(size: 16))
                 }

                 HStack {
                     Image(systemName: "tag")
                         .font(.system(size: 24))
                         .foregroundColor(.blue)
                     Picker("Selecciona una categoría", selection: $selectedCategoryId) {
                         ForEach(categories) { category in
                             Text(category.name)
                                 .font(.system(size: 16))
                                 .tag(category.id as Int?)
                                 .multilineTextAlignment(.center)
                         }
                     }
                     .pickerStyle(MenuPickerStyle())
                     .frame(maxWidth: .infinity)
                     .frame(height: 20)
                     .padding()
                     .background(Color(.systemGray6))
                     .cornerRadius(10)
                     .font(.system(size: 16))
                 }
                 
                 HStack {
                     Image(systemName: "person")
                         .font(.system(size: 24))
                         .foregroundColor(.blue)
                     TextField("Usuario de la plataforma", text: $newPlatformUsername)
                         .padding()
                         .background(Color(.systemGray6))
                         .cornerRadius(10)
                 }

                 HStack {
                     Image(systemName: "key")
                         .font(.system(size: 24))
                         .foregroundColor(.blue)
                     if isPasswordVisible {
                         TextField("Contraseña", text: $newPassword)
                             .padding()
                             .background(Color(.systemGray6))
                             .cornerRadius(10)
                             .onChange(of: newPassword) {
                                 passwordStrength = evaluatePasswordStrength(newPassword)
                             }
                     } else {
                         SecureField("Contraseña", text: $newPassword)
                             .padding()
                             .background(Color(.systemGray6))
                             .cornerRadius(10)
                             .onChange(of: newPassword) {
                                 passwordStrength = evaluatePasswordStrength(newPassword)
                             }
                     }
                     Button(action: {
                         isPasswordVisible.toggle()
                     }) {
                         Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                             .font(.system(size: 24))
                             .foregroundColor(.gray)
                     }
                     Button(action: {
                         newPassword = generateSecurePassword()
                         passwordStrength = evaluatePasswordStrength(newPassword)
                     }) {
                         Image(systemName: "wand.and.stars")
                             .font(.system(size: 24))
                             .foregroundColor(.yellow)
                     }
                 }
                 
                 
           
                HStack {
                Image(systemName: "key.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                if isConfirmPasswordVisible {
                TextField("Confirmar Contraseña", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                } else {
                SecureField("Confirmar Contraseña", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                }
                    Button(action: {
                    isConfirmPasswordVisible.toggle()
                    }) {
                Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    }
                }


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
             .padding()

             if let errorMessage = errorMessage {
                 Text(errorMessage)
                     .foregroundColor(.red)
             }

             if let successMessage = successMessage {
                 Text(successMessage)
                     .foregroundColor(.green)
             }

             Button(action: addPassword) {
                 Text("Agregar")
                     .font(.headline)
                     .foregroundColor(.white)
                     .padding()
                     .frame(maxWidth: .infinity)
                     .background(Color.green)
                     .cornerRadius(10)
             }
             .padding()
         }
         .padding()
         .onAppear(perform: loadPlatformsAndCategories)
     }



    
    private var editPasswordView: some View {
        
        
            VStack {
                Text("Editar Contraseña")
                    .font(.title2)
                    .bold()
                    .padding()

                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    HStack {
                        Image(systemName: "network")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        Picker("Selecciona una plataforma", selection: $selectedPlatformId) {
                            ForEach(platforms) { platform in
                                Text(platform.platform_name)
                                    .font(.system(size: 16))
                                    .tag(platform.id as Int?)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.system(size: 16))
                    }

                    HStack {
                        Image(systemName: "tag")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        Picker("Selecciona una categoría", selection: $selectedCategoryId) {
                            ForEach(categories) { category in
                                Text(category.name)
                                    .font(.system(size: 16))
                                    .tag(category.id as Int?)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.system(size: 16))
                    }
                    
                    
                    HStack {
                        Image(systemName: "person")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        TextField("Usuario de la plataforma", text: $editItemPlatformUsername)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }

                    HStack {
                        Image(systemName: "key")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                        if isEditPasswordVisible {
                            TextField("Contraseña", text: $editItemPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onChange(of: editItemPassword) {
                                    passwordStrength = evaluatePasswordStrength(editItemPassword)
                                    
                                    editItemPasswordDidChange = true
                                    isInitialLoad = false
                                }
                        } else {
                            SecureField("Contraseña", text: $editItemPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .onChange(of: editItemPassword) {
                                    passwordStrength = evaluatePasswordStrength(editItemPassword)
                                }
                        }
                        Button(action: {
                            isEditPasswordVisible.toggle()
                        }) {
                            Image(systemName: isEditPasswordVisible ? "eye.slash" : "eye")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                        Button(action: {
                            editItemPassword = generateSecurePassword()
                        }) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    
                    HStack {
                    Image(systemName: "key.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    if isConfirmNewPasswordVisible {
                    TextField("Confirmar Contraseña", text: $confirmnewPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                    } else {
                    SecureField("Confirmar Contraseña", text: $confirmnewPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                    }
                        Button(action: {
                            isConfirmNewPasswordVisible.toggle()
                        }) {
                    Image(systemName: isConfirmNewPasswordVisible ? "eye.slash" : "eye")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                        }
                    }
                    
                    
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
                .padding()

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                }

                Button(action: editPassword) {
                    Text("Editar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
            .onAppear(perform: loadPlatformsAndCategories)
        }

    
    
    private func loadPasswords() {
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            self.isLoading = false
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/Passwords/user/\(userId)") else {
           print("URL inválida")
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No se recibió respuesta del servidor")
                    return
                }

                do {
                    let response = try JSONDecoder().decode(PasswordResponse.self, from: data)
                    if response.success {
                        self.passwords = response.data.map { passwordData in
                            PasswordEntry(
                                id: passwordData.passwordId,
                                platform: passwordData.platform.platform_name,
                                category: passwordData.category.name,
                                username: passwordData.platformUsername,
                                password: passwordData.password,
                                platformId: nil,
                                categoryId: nil
                            )
                        }
                    } else {
                        print(response.message)
                    }
                } catch {
                    print("Error decodificando datos: \(error.localizedDescription)")
                }
            }
        }.resume()
    }



   

    
    
    
    
    
    private func loadPlatformsAndCategories() {
            guard let userId = userData.user?.id else {
                print("Usuario no identificado")
                return
            }

            // Cargar plataformas
            guard let platformsURL = URL(string: "http://localhost:8080/api/Platforms/user/\(userId)") else {
                print("URL inválida")
                return
            }

            URLSession.shared.dataTask(with: platformsURL) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print ("Error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        print("No se recibió respuesta del servidor")
                    }
                    return
                }

                do {
                    let response = try JSONDecoder().decode(PlatformResponse.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            self.platforms = response.data
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(response.message)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        print( "Error decodificando datos: \(error.localizedDescription)")
                    }
                }
            }.resume()

            // Cargar categorías
            guard let categoriesURL = URL(string: "http://localhost:8080/api/Categories/user/\(userId)") else {
                print("URL inválida")
                return
            }

            URLSession.shared.dataTask(with: categoriesURL) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print ("Error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        print("No se recibió respuesta del servidor")
                    }
                    return
                }

                do {
                    let response = try JSONDecoder().decode(CategoryResponse.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            self.categories = response.data
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(response.message)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        print( "Error decodificando datos: \(error.localizedDescription)")
                    }
                }
            }.resume()
        
        
      
                if selectedPlatformId == nil, let firstPlatform = platforms.first {
                    selectedPlatformId = firstPlatform.id
                }
                if selectedCategoryId == nil, let firstCategory = categories.first {
                    selectedCategoryId = firstCategory.id
                }
        }
    
    
    
    
    private func addPassword() {
        guard let platformId = selectedPlatformId, let categoryId = selectedCategoryId, !newPlatformUsername.isEmpty, !newPassword.isEmpty else {
            self.errorMessage = "Por favor, complete todos los campos"
            return
        }
        
        guard newPassword == confirmPassword else {
                    errorMessage = "Las contraseñas no coinciden"
                    return
                }

        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/Passwords") else {
            print("URL inválida")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let newPasswordDetails = CreatePasswordModelAdd(platformUsername: newPlatformUsername, password: newPassword, confirmPassword: confirmPassword, platformId: platformId, categoryId: categoryId, userId: userId)

        do {
            request.httpBody = try JSONEncoder().encode(newPasswordDetails)
        } catch {
            print("Error codificando los detalles de la contraseña")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print( "Error: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    print("No se recibió respuesta del servidor")
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(APIResponsePassword<PasswordData>.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        let newPasswordEntry = PasswordEntry(
                            id: response.data.passwordId,
                            platform: response.data.platform.platform_name,
                            category: response.data.category.name,
                            username: response.data.platformUsername,
                            password: response.data.password,
                            platformId: platformId,
                            categoryId: categoryId
                        )
                        self.passwords.append(newPasswordEntry)
                        self.newPlatformUsername = ""
                        self.newPassword = ""
                        self.selectedPlatformId = nil
                        self.selectedCategoryId = nil
                        self.isAddingItem = false
                    }
                } else {
                    DispatchQueue.main.async {
                        print(response.message)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    print( "Error decodificando datos: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    
    
    private func editPassword() {
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }
        
        if !isInitialLoad && editItemPassword != "" && editItemPassword != confirmnewPassword {
            errorMessage = "Las contraseñas no coinciden"
            return
        }


        guard let selectedIndex = selectedItemIndex else {
            print("No se seleccionó ninguna contraseña")
            return
        }

        let passwordId = passwords[selectedIndex].id

        guard let url = URL(string: "http://localhost:8080/api/Passwords/\(passwordId)") else {
            print("URL inválida")
            return
        }

        let updatedPasswordDetails = CreatePasswordModel(
            platformUsername: editItemPlatformUsername,
            password: editItemPassword,
            platformId: selectedPlatformId ?? 0,
            categoryId: selectedCategoryId ?? 0,
            userId: userId
        )

        do {
            let requestBody = try JSONEncoder().encode(updatedPasswordDetails)

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print("Error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        print("No se recibió respuesta del servidor")
                    }
                    return
                }

                do {
                    let response = try JSONDecoder().decode(PasswordResponse2.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            let newPasswordEntry = PasswordEntry(
                                id: response.data.passwordId,
                                platform: response.data.platform.platform_name,
                                category: response.data.category.name,
                                username: response.data.platformUsername,
                                password: response.data.password,
                                platformId: selectedPlatformId ?? 0,
                                categoryId: selectedCategoryId ?? 0
                            )
                            self.passwords[selectedIndex] = newPasswordEntry
                            self.editItemPlatformUsername = ""
                            self.editItemPassword = ""
                            self.isEditingItem = false
                            self.errorMessage = nil
                            print(response.message)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(response.message)
                        }
                    }

                } catch {
                    DispatchQueue.main.async {
                        print("Error decodificando datos: \(error.localizedDescription)")
                    }
                }
            }.resume()
        } catch {
            print("Error codificando los detalles de la contraseña: \(error.localizedDescription)")
        }
    }


    
    
    
    private func deletePassword(_ id: Int) {
            guard let url = URL(string: "http://localhost:8080/api/Passwords/\(id)") else {
                print("URL inválida")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                       print("Error: \(error.localizedDescription)")
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                       print("No se recibió respuesta del servidor")
                    }
                    return
                }

                do {
                    let response = try JSONDecoder().decode(DeletePasswordResponse.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            self.pass.removeAll { $0.id == id }
                            loadPasswords()
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(response.message)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                       print("Error decodificando datos: \(error.localizedDescription)")
                    }
                }
            }.resume()
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

      private func generateSecurePassword() -> String {
          let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<12).map{ _ in characters.randomElement()! })
      }
  }

  enum PasswordStrength {
      case strong
      case medium
      case weak
  }
    
    




func generateSecurePassword(length: Int = 12) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]|;:',.<>/?"
    return String((0..<length).map{ _ in letters.randomElement()! })
}





struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView()
            .environmentObject(UserData())
    }
}

