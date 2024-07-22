//
//  LoginView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI

enum Field: Hashable {
    case username
    case password
}

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin: Bool = true
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .clear]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                Text(isLogin ? "Login" : "Sign up")
                    .font(.custom("PlayfairDisplay-Bold", size: 35))
                    .bold()
                    .padding(.top, 100)
                VStack {
                    TextField(
                        "Email",
                        text: $email
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .password
                    }
                    .padding(.top, 20)
                    
                    Rectangle()
                        .frame(height: 1)
                    
                    SecureField(
                        "Password",
                        text: $password
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        Authenticate()
                    }
                    .padding(.top, 20)
                    
                    Rectangle()
                        .frame(height: 1)
                }
                Spacer()
                VStack {
                    Button(action: {
                        Authenticate()
                    }, label: {
                        Text(isLogin ? "Login" : "Sign up")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    })
                    Button(action: {
                        isLogin.toggle()
                    }, label: {
                        Text(isLogin ? "Don't have an accont? signup" : "Already have an account? Login")
                    })
                }
                .padding(.bottom, 20)
            }
            .padding(30)
        }
    }
    
    private func Authenticate() {
        if isLogin {
            viewModel.login(email: email, password: password) { result in
                switch result {
                case .success(let success):
                    print("Logged in")
                case .failure(let failure):
                    print("failed to login \(failure.localizedDescription)")
                }
            }
        } else {
            viewModel.register(email: email, password: password) { result in
                switch result {
                case .success(let success):
                    print("Registered")
                case .failure(let failure):
                    print("failed to register")
                }
            }
        }
    }
}