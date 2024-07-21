//
//  FavoriteView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavoriteView: View {
    
    @State private var isFetching: Bool = true
    @State private var showLoading: Bool = false
    
    //temp
    @State private var favoriteProducts: [Product] = [Product]()
    private let categories = ["All", "Jewelery", "Electronics", "Men's Clothing", "Women's Clothing"]
    
    var body: some View {
        VStack {
            TagLineFavoriteView()
            Spacer()
            if !isFetching {
                if favoriteProducts.count > 0 {
                    List {
                        ForEach(favoriteProducts.indices, id: \.self) { i in
                            VStack {
                                HStack {
                                    WebImage(url: URL(string: favoriteProducts[i].image))
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                    VStack (alignment: .leading) {
                                        Text(favoriteProducts[i].title)
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                        Text(PriceFormatter.shared.format(price: favoriteProducts[i].price))
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                            
                                    }
                                    Spacer()
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    print("add \(favoriteProducts[i].title) to cart")
                                    addTocart(favoriteProducts[i])
                                }) {
                                    Label("Edit", systemImage: "cart")
                                }
                                .tint(.blue)

                                Button(role: .destructive, action: {
                                    deleteItem(favoriteProducts[i])
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                    .ignoresSafeArea(edges: .horizontal)
                    VStack {
                        Button(action: {
                            showLoading = true
                            for product in favoriteProducts {
                                addTocart(product)
                            }
                            showLoading = false
                        }, label: {
                            Text("Add all items to cart")
                        })
                        .buttonStyle(BorderedButtonStyle())
                    }
                } else {
                    Text("No items added yet")
                }
                
            } else {
                ProgressView()
            }
            Spacer()
            if showLoading {
                ProgressView("Adding to carts")
            }
        }
        .task {
            DataPersistenceManager.shared.fetchFavoriteItems { result in
                switch result {
                case .success(let products):
                    self.favoriteProducts = products
                    self.isFetching = false
                case .failure(let failure):
                    print("failed to fetch products")
                }
            }
        }
    }
    private func deleteItem(_ item: Product) {
        if let index = favoriteProducts.firstIndex(where: { $0.id == item.id }) {
            let product = favoriteProducts[index]
            DataPersistenceManager.shared.deleteFavoriteItem(item: product) { result in
                switch result {
                case .success(let success):
                    print("item deleted")
                    favoriteProducts.remove(at: index)
                case .failure(let failure):
                    print("failed to delete")
                }
            }
        }
    }
    
    private func addTocart(_ product: Product) {
        let cartItem = CartItem(quantity: 1, id: product.id, title: product.title, price: product.price, description: product.description, category: product.category, image: product.image, rate: product.rating.rate, count: product.rating.count)
        DataPersistenceManager.shared.addToCartItems(item: cartItem) { result in
            switch result {
            case .success(let success):
                print("item added")
            case .failure(let failure):
                print("failed to add")
            }
        }
    }
}

struct TagLineFavoriteView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Check out now \nbefore it's ")
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                + Text("Too Late")
                    .font(.custom("PlayfairDisplay-Bold", size: 35))
                Spacer()
            }
            .padding(.leading, 15)
        }
    }
}
