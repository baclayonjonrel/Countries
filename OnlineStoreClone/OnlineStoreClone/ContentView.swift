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
        .onAppear {
            let user = loginViewModel.currentUser
            print(user?.uid)
            //email Optional("fxi8SHlFNrX665bU1F5NPElsYct1")
            //test Optional("QRoWH2AJr5fw9JpBuwWOzT1XHAm1")
        }
    }
}

#Preview {
    ContentView()
}


