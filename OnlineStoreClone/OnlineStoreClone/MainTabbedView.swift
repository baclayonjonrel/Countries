//
//  MainTabbedView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI

struct MainTabbedView: View {
    @State var selectedTab = 0
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView()
                }
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
                NavigationStack {
                    FavoriteView()
                }
                .tabItem {
                    Image(systemName: "heart")
                    Text("Loved")
                }
                .tag(1)
                NavigationStack {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person")
                    Text("Me")
                }
                .tag(2)
            }
            .tint(.red)
        }
    }
}
