//
//  CustomAlertWithTF.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI

struct CustomAlertViewWithTextField: View {
    @State var title: String
    @State var placeHolder: String
    @State private var inputText: String = ""
    @Binding var isPresenting: Bool
    var onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .padding()

                TextField(placeHolder, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Spacer()
                HStack(spacing: 0) {
                    Button(action: {
                        isPresenting = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    Divider()
                    Button(action: {
                        onSubmit(inputText)
                    }) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 10)
            }
            .frame(width: 300, height: 200)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
            .transition(.scale)
            .zIndex(1)
        }
    }
}
