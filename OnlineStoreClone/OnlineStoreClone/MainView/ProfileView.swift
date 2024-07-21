//
//  ProfileView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    @State private var purchaseHistory: [CartItem] = [CartItem]()
    @State private var isFetching: Bool = true
    
    var body: some View {
        VStack {
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(.circle)
            Text("Jonrel Baclayon")
            Text("baclayonjonrel@gmail.com")
            Divider()
                .padding(.horizontal, 10)
            
            
            List {
                Section {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("Jonrel")
                        Image(systemName: "pencil")
                    }
                    HStack {
                        Text("Bio")
                        Spacer()
                        Text("Set Now")
                        Image(systemName: "pencil")
                    }
                    HStack {
                        Text("Gender")
                        Spacer()
                        Text("Set Now")
                        Image(systemName: "pencil")
                    }
                    HStack {
                        Text("Birthday")
                        Spacer()
                        Text("Set Now")
                        Image(systemName: "pencil")
                    }
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("baclayonjonrel@gmail.com")
                        Image(systemName: "pencil")
                    }
                } header: {
                    Text("Personal information")
                }
                Section {
                    if !isFetching {
                        ScrollView {
                            ForEach(purchaseHistory.indices, id: \.self) { item in
                                HStack {
                                    WebImage(url: URL(string: purchaseHistory[item].image))
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                    VStack {
                                        Text(purchaseHistory[item].title)
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                        Text(PriceFormatter.shared.format(price: purchaseHistory[item].price))
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Text("Quantity: \(purchaseHistory[item].quantity ?? 1)")
                                        .font(.system(size: 10))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    } else {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    }
                } header: {
                    Text("Purchase History")
                }
            }
            
            Spacer()
        }
        .padding(.top, 40)
        .onAppear {
            DataPersistenceManager.shared.fetchHistoryItems { result in
                switch result {
                case .success(let history):
                    purchaseHistory = history
                    isFetching = false
                    print("fetched purchased history \(purchaseHistory.count)")
                case .failure(let failure):
                    print("Failed: \(failure)")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
