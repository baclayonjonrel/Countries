//
//  ToolBarItems.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/21/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct SharedToolBarItem {
    static func CartView(showCartView: Binding<Bool>, itemCount: Int) -> some View {
        Button {
            showCartView.wrappedValue = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)

                if itemCount > 0 {
                    Text("\(itemCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 15, y: -10)
                }
            }
        }
    }
    
    static func userLogo() -> some View {
        VStack {
            Image(.logo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.black.opacity(0.5), lineWidth: 2)
                )
        }
    }

    struct SearchBar: View {
        @Binding var text: String

        var body: some View {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(minWidth: 0, maxWidth: .infinity)
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            .padding(EdgeInsets(top: 3, leading: 2, bottom: 3, trailing: 1))
            .background(Color(.systemGray6))
            .cornerRadius(10.0)
        }
    }
}


