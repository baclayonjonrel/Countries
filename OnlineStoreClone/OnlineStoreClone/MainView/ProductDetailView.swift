//
//  ProductDetailView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProductDetailView: View {
    let selectedProduct: Product
    let recommendedProducts: [Product]
    @State private var showFullDescription = false
    @State private var number = 1
    @State private var addedToFavorites = false
    @State private var showCartView: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    WebImage(url: URL(string: selectedProduct.image))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width, height: geo.size.height / 2)
                        .background()
                    Divider()
                    HStack {
                        Text(PriceFormatter.shared.format(price: selectedProduct.price))
                        Spacer()
                        Button {
                            if !DataPersistenceManager.shared.isItemInFavorites(id: Int64(selectedProduct.id)) {
                                DataPersistenceManager.shared.addToFavorites(item: selectedProduct) { result in
                                    switch result {
                                    case .success(let success):
                                        print("Success")
                                        addedToFavorites = true
                                    case .failure(let failure):
                                        print("Failed")
                                    }
                                }
                            } else {
                                print("item already exist in db")
                            }
                        } label: {
                            Image(systemName: addedToFavorites ? "heart.fill" : "heart")
                        }

                    }
                    .padding(.horizontal)
                    Text(selectedProduct.title)
                        .font(.custom("PlayfairDisplay-Regular", size: 20))
                        .multilineTextAlignment(.leading)
                    HStack {
                        StarRatingView(rating: selectedProduct.rating.rate)
                        Spacer()
                        Text("\(selectedProduct.rating.count) left")
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    Text("Product Description")
                        .font(.headline)
                    DescriptionView(showFullDescription: $showFullDescription, selectedProduct: selectedProduct)
                    Divider()
                    
                    NavigationLink(destination: ReviewsView()) {
                        HStack {
                            Text("Reviews")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.horizontal, 10)
                    }
                    Divider()
                    AddToCartView(number: $number, product: selectedProduct)
                    Divider()
                    RecommendedView(recommendedProducts: recommendedProducts)
                    Spacer()
                }
            }
            .onAppear {
                addedToFavorites = DataPersistenceManager.shared.isItemInFavorites(id: Int64(selectedProduct.id))
            }
        }
        
    }
}

struct AddToCartView: View {
    @Binding var number: Int
    let product: Product
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    let cartItem = CartItem(quantity: number, id: product.id, title: product.title, price: product.price, description: product.description, category: product.category, image: product.image, rate: product.rating.rate, count: product.rating.count)
                    if !DataPersistenceManager.shared.isItemInCart(id: Int64(product.id)) {
                        DataPersistenceManager.shared.addToCartItems(item: cartItem) { result in
                            switch result {
                            case .success(let success):
                                print("Successfully added to cart")
                            case .failure(let failure):
                                print("failed adding to cart")
                            }
                        }
                    } else {
                        print("Item is already on the cart, updating quantity")
                        DataPersistenceManager.shared.updateCartItemQuantity(id: product.id, newQuantity: number) { result in
                            switch result {
                            case .success(let success):
                                print("success")
                            case .failure(let failure):
                                print("failed")
                            }
                        }
                    }
                }
            }) {
                Label("Add to cart", systemImage: "cart")
            }
            .padding(.leading, 10)
            Spacer()
            HStack {
                Button(action: {
                    if number > 0 {
                        number -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .padding(.trailing, 2)
                        .opacity(number > 0 ? 1 : 0.5)
                }
                Divider()
                Text("\(number)")
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                Divider()
                Button(action: {
                    number += 1
                }) {
                    Image(systemName: "plus")
                        .padding(.trailing, 2)
                }
            }
            .border(.black.opacity(0.7), width: 0.5)
            .padding(.trailing, 10)
        }
    }
}


struct RecommendedView: View {
    
    let recommendedProducts: [Product]
    
    var body: some View {
        Text("You may also like")
        ScrollView (.horizontal, showsIndicators: false) {
            HStack (spacing: 5) {
                ForEach(0 ..< recommendedProducts.count) { item in
                    NavigationLink(destination: ProductDetailView(selectedProduct: recommendedProducts[item], recommendedProducts: recommendedProducts)) {
                        ProductCardView(product: recommendedProducts[item])
                            .padding(.horizontal, 5)
                    }
                }
            }
        }
    }
}

struct DescriptionView: View {
    @Binding var showFullDescription: Bool
    let selectedProduct: Product
    var body: some View {
        if showFullDescription {
            VStack {
                Text(selectedProduct.description ?? "")
                    .padding(.horizontal, 10)
                Button(action: {
                    withAnimation {
                        showFullDescription.toggle()
                    }
                }) {
                    Text("See Less")
                        .foregroundColor(.blue)
                }
            }
        } else {
            VStack {
                Text(selectedProduct.description ?? "")
                    .lineLimit(2)
                    .padding(.horizontal, 10)
                Button(action: {
                    withAnimation {
                        showFullDescription.toggle()
                    }
                }) {
                    Text("See More")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ReviewsView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("No reviews yet")
                Spacer()
            }
            Spacer()
        }
    }
}
