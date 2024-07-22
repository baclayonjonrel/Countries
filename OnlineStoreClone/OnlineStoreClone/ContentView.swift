//
//  ContentView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            if loginViewModel.currentUser == nil {
                LoginView(viewModel: loginViewModel)
            } else {
                MainTabbedView(viewModel: loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}


