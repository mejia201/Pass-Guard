//  HistoryView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 20/5/24.
//

import SwiftUI

struct HistoryView: View {
    
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    
    @State private var passwordHistory: [PasswordHistoryData]?
    @State private var isDeleteAlertPresented = false
    @State private var selectedItemIndex: Int?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }

    var body: some View {
        NavigationView {
            VStack {
                if let history = passwordHistory {
                    List(history, id: \.historyId) { historyData in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Plataforma: \(historyData.platformName)")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.blue)
                            Text("Contraseña antigua: \(historyData.oldPassword)")
                                .font(.body)
                                .bold()
                                .foregroundColor(.secondary)
                            Text("Fecha de cambio: \(self.formattedDate(from: historyData.changeDate))")
                                .font(.body)
                                .foregroundColor(.gray)
                         
                            Button(action: {
                                if let index = history.firstIndex(where: { $0.historyId == historyData.historyId }) {
                                    selectedItemIndex = index
                                    isDeleteAlertPresented = true
                                }
                            }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .alert(isPresented: $isDeleteAlertPresented) {
                                Alert(
                                    title: Text("Confirmar Eliminación"),
                                    message: Text("¿Estás seguro de que deseas eliminar el historial? Esta acción no se puede deshacer."),
                                    primaryButton: .destructive(Text("Eliminar")) {
                                        if let index = selectedItemIndex {
                                            deleteHistory(history[index].historyId)
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        .padding(8)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                    }
                    .scrollContentBackground(.hidden)
                    .navigationBarTitle("Historial de Contraseñas", displayMode: .inline)
                } else {
                    Text("No hay historial disponible")
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                fetchPasswordHistory()
            }
        }
    }

    func fetchPasswordHistory() {
        guard let userId = userData.user?.id else {
            print("Usuario no identificado")
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/api/password-history?userId=\(userId)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let passwordHistoryResponse = try decoder.decode(PasswordHistoryResponse.self, from: data)
                DispatchQueue.main.async {
                    self.passwordHistory = passwordHistoryResponse.data
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    private func deleteHistory(_ id: Int) {
        guard let url = URL(string: "http://localhost:8080/api/password-history/\(id)") else {
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
                let response = try JSONDecoder().decode(DeleteHistoryResponse.self, from: data)
                if response.success {
                    DispatchQueue.main.async {
                        self.passwordHistory?.removeAll { $0.historyId == id }
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

    

    func formattedDate(from dateString: String) -> String {
        if let date = dateFormatter.date(from: dateString) {
            let formattedDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            return formattedDate
        } else {
            return "Fecha Desconocida"
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(UserData())
    }
}

