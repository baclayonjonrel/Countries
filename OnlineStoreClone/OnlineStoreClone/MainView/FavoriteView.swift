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
    @State private var favoriteProducts: [Product] = [Product]()
    @State private var searchText: String = ""
    @State private var showCartView: Bool = false
    @State private var itemsSavedToCart = [CartItem]()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var successfulAdds = 0
    @State private var failedAdds = 0
    @State private var remainingAdds = 0
    
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                TagLineFavoriteView()
                Spacer()
                if !isFetching {
                    if favoriteProducts.count > 0 {
                        List {
                            ForEach(favoriteProducts.indices, id: \.self) { i in
                                NavigationLink(destination: ProductDetailView(selectedProduct: favoriteProducts[i], recommendedProducts: favoriteProducts, viewModel: viewModel)) {
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
                                addAllToCart()
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
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                Spacer()
                if showLoading {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Adding to Carts")
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }            }
            }
        }
        .task {
            DataPersistenceManager.shared.fetchFavoriteItems(userId: viewModel.currentUser?.uid ?? "") { result in
                switch result {
                case .success(let products):
                    self.favoriteProducts = products
                    self.isFetching = false
                case .failure(let failure):
                    print("failed to fetch products")
                }
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SharedToolBarItem.userLogo()
            }
            ToolbarItem(placement: .topBarTrailing) {
                SharedToolBarItem.CartView(showCartView: $showCartView, itemCount: $itemsSavedToCart.count)
            }
        }
        .fullScreenCover(isPresented: $showCartView, content: {
            CartView(viewModel: viewModel)
                .onDisappear {
                    DataPersistenceManager.shared.fetchCartItems(userId: viewModel.currentUser?.uid ?? "") { result in
                        switch result {
                        case .success(let cartItems):
                            itemsSavedToCart = cartItems
                        case .failure(let failure):
                            print("Failed to fetch cart items")
                        }
                    }
                }
        })
        .onChange(of: searchText) {
            print(searchText)
        }
        .onAppear {
            DataPersistenceManager.shared.fetchCartItems(userId: viewModel.currentUser?.uid ?? "") { result in
                switch result {
                case .success(let cartItems):
                    itemsSavedToCart = cartItems
                case .failure(let failure):
                    print("Failed to fetch cart items")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Cart Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    private func deleteItem(_ item: Product) {
        if let index = favoriteProducts.firstIndex(where: { $0.id == item.id }) {
            let product = favoriteProducts[index]
            DataPersistenceManager.shared.deleteFavoriteItem(userId: viewModel.currentUser?.uid ?? "", item: product) { result in
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
    
    private func addAllToCart() {
        remainingAdds = favoriteProducts.count
        successfulAdds = 0
        failedAdds = 0
        for product in favoriteProducts {
            addTocart(product)
        }
    }

    private func addTocart(_ product: Product) {
        let cartItem = CartItem(quantity: 1, id: product.id, title: product.title, price: product.price, description: product.description, category: product.category, image: product.image, rate: product.rating.rate, count: product.rating.count)
        if !DataPersistenceManager.shared.isItemInCart(userId: viewModel.currentUser?.uid ?? "", id: Int64(product.id)) {
            DataPersistenceManager.shared.addToCartItems(userId: viewModel.currentUser?.uid ?? "", item: cartItem) { result in
                switch result {
                case .success:
                    successfulAdds += 1
                    print("success adding fav to cart")
                case .failure:
                    failedAdds += 1
                    print("success adding fav to cart")
                }
                remainingAdds -= 1
                if remainingAdds == 0 {
                    alertMessage = "Items added to cart"
                    showAlert = true
                }
            }
        } else {
            DataPersistenceManager.shared.updateCartItemQuantity(userId: viewModel.currentUser?.uid ?? "", id: product.id, newQuantity: 1) { result in
                switch result {
                case .success:
                    successfulAdds += 1
                    print("success adding fav to cart")
                case .failure:
                    failedAdds += 1
                    print("success adding fav to cart")
                }
                remainingAdds -= 1
                if remainingAdds == 0 {
                    alertMessage = "Items added to cart: \(successfulAdds)"
                    showAlert = true
                }
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
