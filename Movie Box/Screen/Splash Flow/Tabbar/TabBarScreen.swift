//
//  TabBarScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

enum TabItem: CaseIterable {
    case home
    case movies
    case notes
    case setting

    var icon: String {
        switch self {
        case .home: return "ic_home"
        case .movies: return "ic_movie"
        case .notes: return "ic_notes"
        case .setting: return "ic_setting"
        }
    }
}

struct TabBarScreen: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        VStack {
            
            ZStack {
                HomeScreen()
                    .opacity(selectedTab == .home ? 1 : 0)
                
                MoviesScreen()
                    .opacity(selectedTab == .movies ? 1 : 0)
                
                NotesScreen()
                    .opacity(selectedTab == .notes ? 1 : 0)
                
                SettingScreen()
                    .opacity(selectedTab == .setting ? 1 : 0)
                 
                VStack {
                    Spacer()
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    TabBarScreen()
}

struct CustomTabBar: View {

    @Binding var selectedTab: TabItem

    var body: some View {

        HStack {

            ForEach(TabItem.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    ZStack {
                        Image(tab.icon)
                            .resizable()
                            .frame(width: 24, height: 24, alignment: .center)
                    }
                    .padding(16)
                    .frame(width: 72)
                    .background(
                        LinearGradient( colors: [selectedTab == tab ? .skyBlue : .clear, selectedTab == tab ? .greenColour : .clear],startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    
                    .cornerRadius(32)
                }
            }
        }
        .padding(4)
        .background(
            ZStack { }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.whiteColour.opacity(0.5))
            .blur(radius: 30)
        )
        .cornerRadius(32)
    }
}
