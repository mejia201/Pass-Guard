//
//  CategoriesView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI

struct CategoriesView: View {
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isAddingItem = false
    @State private var isEditingItem = false
    @State private var newCategoryName = ""
    @State private var newCategoryDescription = ""
    @State private var editItemName = ""
    @State private var editItemDescription = ""
    @State private var categories: [Category] = []
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
                } else if categories.isEmpty {
                    Text("No hay categorías disponibles")
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(categories) { category in
                            HStack {
                                Image(systemName: "note")
                                    .foregroundColor(.blue)
                                Text(category.name)
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    if let index = categories.firstIndex(where: { $0.id == category.id }) {
                                        selectedItemIndex = index
                                        editItemName = category.name
                                        editItemDescription = category.description ?? ""
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
                                message: Text("¿Estás seguro de que deseas eliminar la categoria? Esta acción no se puede deshacer."),
                                primaryButton: .destructive(Text("Eliminar")) {
                                    deleteCategory(category.id)
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
            .navigationBarTitle("Categorías", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.isAddingItem.toggle()
            }) {
                Image(systemName: "plus")
            }
            )
            .sheet(isPresented: $isAddingItem) {
                addCategoryView
            }
            .sheet(isPresented: $isEditingItem) {
                editCategoryView
            }
            .onAppear(perform: loadCategories)
        }
    }

    private var addCategoryView: some View {
        VStack {
            Text("Agregar nueva Categoría")
                .font(.title2)
                .bold()
                .padding()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "menucard.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    TextField("Nombre", text: $newCategoryName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

                HStack {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    TextField("Descripción", text: $newCategoryDescription)
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

            Button(action: addCategory) {
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

    private var editCategoryView: some View {
        VStack {
            Text("Editar Categoría")
                .font(.title2)
                .bold()
                .padding()

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "menucard.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    TextField("Nombre de la Categoría", text: $editItemName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    TextField("Descripción", text: $editItemDescription)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            .padding()

            Button(action: editCategory) {
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

    
    //function for load categories
    private func loadCategories() {
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            self.isLoading = false
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/Categories/user/\(userId)") else {
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
                    let response = try JSONDecoder().decode(CategoryResponse.self, from: data)
                    if response.success {
                        self.categories = response.data
                    } else {
                        print(response.message)
                    }
                } catch {
                   print("Error decodificando datos: \(error.localizedDescription)")
                }
            }
        }.resume()
    }



    //function for add categories
    private func addCategory() {
        guard !newCategoryName.isEmpty else {
            self.errorMessage = ("Por favor, complete todos los campos")
            return
        }
        
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/api/Categories") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let newCategoryDetails = CreateCategoryModel(categoryName: newCategoryName, description: newCategoryDescription, userId: userId)
        
        do {
            request.httpBody = try JSONEncoder().encode(newCategoryDetails)
        } catch {
            print("Error codificando los detalles de la categoría")
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
                let response = try JSONDecoder().decode(APIResponse<Category>.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        self.categories.append(response.data)
                        self.newCategoryName = ""
                        self.newCategoryDescription = ""
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




    
    //function for adit categories
    private func editCategory() {
        guard let userId = userData.user?.id else {
            print( "Usuario no identificado")
            return
        }
        
        guard let selectedIndex = selectedItemIndex else {
            print( "No se seleccionó ninguna categoría")
            return
        }
        
        let categoryId = categories[selectedIndex].id
        
        guard let url = URL(string: "http://localhost:8080/api/Categories/\(categoryId)") else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedCategoryDetails = CreateCategoryModel(categoryName: editItemName, description: editItemDescription, userId: userId)
        
        do {
            request.httpBody = try JSONEncoder().encode(updatedCategoryDetails)
        } catch {
            print("Error codificando los detalles de la categoría")
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
                let response = try JSONDecoder().decode(APIResponse<Category>.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        self.categories[selectedIndex] = response.data
                        self.editItemName = ""
                        self.editItemDescription = ""
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
                   print( "Error decodificando datos: \(error.localizedDescription)")
                }
            }
        }.resume()
    }


    //funtion for delete categories
  
        private func deleteCategory(_ id: Int) {
            guard let url = URL(string: "http://localhost:8080/api/Categories/\(id)") else {
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
                    let response = try JSONDecoder().decode(DeleteCategoryResponse.self, from: data)
                    if response.success {
                        DispatchQueue.main.async {
                            self.categories.removeAll { $0.id == id }
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

      
  
    


struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(UserData())
    }
}
