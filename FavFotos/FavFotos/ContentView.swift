//
//  ContentView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/08.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            FakeView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

struct FakeView: View {
    var body: some View {
        VStack {
            Text("FILLER")
        }
    }
}
