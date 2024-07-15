//
//  PlatformsView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI

struct PlatformsView: View {
    
      @EnvironmentObject var userData: UserData
      @Environment(\.presentationMode) var presentationMode
    
       @State private var isAddingItem = false
       @State private var isEditingItem = false
       @State private var newPlatformName = ""
       @State private var newPlatformURL = ""
       @State private var newPlatformDescription = ""
       @State private var editItemName = ""
       @State private var editItemURL = ""
       @State private var editItemDescription = ""
       @State private var platforms: [Platform] = []
       @State private var selectedItemIndex: Int?
       @State private var isLoading = true
       @State private var errorMessage: String?
       @State private var successMessage: String?
       @State private var isDeleteAlertPresented = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                if isLoading {
                    ProgressView()
                } else if platforms.isEmpty {
                    Text("No hay plataformas disponibles")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(platforms) { platform in
                            HStack {
                                Image(systemName: "macbook.and.iphone")
                                    .foregroundColor(.blue)
                                Text(platform.platform_name)
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    if let index = platforms.firstIndex(where: { $0.id == platform.id }) {
                                        selectedItemIndex = index
                                        editItemName = platform.platform_name
                                        editItemURL = platform.url
                                        editItemDescription = platform.description ?? ""
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
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                    }
                                }
                                .alert(isPresented: $isDeleteAlertPresented) {
                                    Alert(
                                        title: Text("Confirmar Eliminación"),
                                        message: Text("¿Estás seguro de que deseas eliminar la plataforma? Esta acción no se puede deshacer."),
                                        primaryButton: .destructive(Text("Eliminar")) {
                                            deletePlatform(platform.id)
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
            .navigationBarTitle("Plataformas", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.isAddingItem.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isAddingItem) {
                addPlatformView
            }
            .sheet(isPresented: $isEditingItem) {
                editPlatformView
            }
            .onAppear(perform: loadPlatforms)
        }
    }


    private var addPlatformView: some View {
          VStack {
              Text("Agregar nueva Plataforma")
                  .font(.title2)
                  .bold()
                  .padding()

              VStack(alignment: .leading, spacing: 16) {
                  HStack {
                      Image(systemName: "platter.2.filled.ipad")
                          .font(.system(size: 24))
                          .foregroundColor(.blue)
                      TextField("Nombre", text: $newPlatformName)
                          .padding()
                          .background(Color(.systemGray6))
                          .cornerRadius(10)
                  }

                  HStack {
                      Image(systemName: "link")
                          .font(.system(size: 24))
                          .foregroundColor(.blue)
                      TextField("URL", text: $newPlatformURL)
                          .padding()
                          .background(Color(.systemGray6))
                          .cornerRadius(10)
                  }

                  HStack {
                      Image(systemName: "text.bubble")
                          .font(.system(size: 24))
                          .foregroundColor(.blue)
                      TextField("Descripción", text: $newPlatformDescription)
                          .padding()
                          .background(Color(.systemGray6))
                          .cornerRadius(10)
                  }
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
              
              Button(action: addPlatform) {
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
      }

    private var editPlatformView: some View {
        VStack {
            Text("Editar Plataforma")
                .font(.title2)
                .bold()
                .padding()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "platter.2.filled.ipad")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    TextField("Nombre", text: $editItemName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                HStack {
                    Image(systemName: "link")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    TextField("URL", text: $editItemURL)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                HStack {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    TextField("Descripción", text: $editItemDescription)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            .padding()

            Button(action: editPlatform) {
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
    }


        private func loadPlatforms() {
         
                guard let userId = userData.user?.id else {
                    print("Usuario no identificado")
                    self.isLoading = false
                    return
                }

                guard let url = URL(string: "http://localhost:8080/api/Platforms/user/\(userId)") else {
                    print("URL inválida")
                    self.isLoading = false
                    return
                }

                URLSession.shared.dataTask(with: url) { data, response, error in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        if let error = error {
                            print ("Error: \(error.localizedDescription)")
                            return
                        }

                        guard let data = data else {
                            print("No se recibió respuesta del servidor")
                            return
                        }

                        do {
                            let response = try JSONDecoder().decode(PlatformResponse.self, from: data)
                            if response.success {
                                self.platforms = response.data
                            } else {
                                print(response.message)
                            }
                        } catch {
                            print( "Error decodificando datos: \(error.localizedDescription)")
                        }
                    }
                }.resume()
            
        }

    private func addPlatform() {
        guard !newPlatformName.isEmpty, !newPlatformURL.isEmpty else {
            self.errorMessage = "Por favor, complete todos los campos"
            return
        }
        
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/api/Platforms") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let newPlatformDetails = CreatePlatformModel(platform_name: newPlatformName, description: newPlatformDescription, url: newPlatformURL, userId: userId)
        
        do {
            request.httpBody = try JSONEncoder().encode(newPlatformDetails)
        } catch {
            print("Error codificando los detalles de la plataforma")
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
                let response = try JSONDecoder().decode(APIResponse<Platform>.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        self.platforms.append(response.data)
                        self.newPlatformName = ""
                        self.newPlatformURL = ""
                        self.newPlatformDescription = ""
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


    private func editPlatform() {
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }
        
        guard let selectedIndex = selectedItemIndex else {
            print("No se seleccionó ninguna plataforma")
            return
        }
        
        let platformId = platforms[selectedIndex].id
        
        guard let url = URL(string: "http://localhost:8080/api/Platforms/\(platformId)") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedPlatformDetails = CreatePlatformModel(platform_name: editItemName, description: editItemDescription, url: editItemURL, userId: userId)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedPlatformDetails)
        } catch {
            print("Error codificando los detalles de la plataforma")
            return
        }
        
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
                let response = try JSONDecoder().decode(APIResponse<Platform>.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        self.platforms[selectedIndex] = response.data
                        self.editItemName = ""
                        self.editItemDescription = ""
                        self.editItemURL = ""
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
    }


        private func deletePlatform(_ id: Int) {
            guard let url = URL(string: "http://localhost:8080/api/Platforms/\(id)") else {
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
                    let response = try JSONDecoder().decode(DeletePlatformResponse.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            self.platforms.removeAll { $0.id == id }
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
}

struct PlatformsView_Previews: PreviewProvider {
    static var previews: some View {
       PlatformsView()
            .environmentObject(UserData())
    }
}
