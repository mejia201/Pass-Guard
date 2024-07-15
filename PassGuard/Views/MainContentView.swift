//
//  MainContentView.swift
//  PassGuard
//
//  Created by Bryan Mejia on 27/5/24.
//

import SwiftUI

struct MainContentView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var userData: UserData
    
    var body: some View {
            VStack(spacing: 0) {
            
                ZStack {
                    contentView(for: selectedTab)
                        .background(Color.white)
                        .edgesIgnoringSafeArea([.top, .horizontal])
                }

                TabBarView(selectedTab: $selectedTab)
                    .frame(height: 90)
                    .padding(.horizontal, 30)
                    .background(Color.white)
                    
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    
    @ViewBuilder
    private func contentView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .categories:
            CategoriesView()
                
        case .platforms:
            PlatformsView()
        case .passwords:
            PasswordsView()
        case .history:
            HistoryView()
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .environmentObject(UserData())
    }
}

