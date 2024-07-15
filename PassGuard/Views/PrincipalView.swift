//
//  PrincipalView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 19/5/24.
//

import SwiftUI

struct PrincipalView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        
        Group {
                   if userData.user == nil {
                       ContentView()
                           .environmentObject(userData)
                   } else {
                       MainContentView()
                           .environmentObject(userData)
                   }
               }
    }
}

struct PrincipalView_Previews: PreviewProvider {
    static var previews: some View {
        PrincipalView()
            .environmentObject(UserData())
    }
}
