//
//  HomeView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    private let categories = ["All", "Jewelery", "Electronics", "Men's Clothing", "Women's Clothing"]
    @State private var selectedIndex = 0
    @State private var isFetching: Bool = true
    @State private var categorizedProducts: [[Product]] = Array(repeating: [], count: 5)
    
    @State private var searchText: String = ""
    @State private var showCartView: Bool = false
    
    @State private var itemsSavedToCart = [CartItem]()
    
    var body: some View {
        VStack {
            Divider()
            TagLineView()
                .padding(.horizontal, 10)
                .padding(.vertical, 0)
            Divider()
                ScrollView (.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0 ..< categories.count, id: \.self) { item in
                            CategoryView(isActive: item == selectedIndex, text: categories[item])
                                .onTapGesture {
                                    selectedIndex = item
                                }
                            }
                    }
                    .padding(.horizontal, 10)
                }
                Divider()
            if !isFetching {
                ScrollView {
                    ForEach(1 ..< categories.count, id: \.self) { item in
                        ProductScrollView(products: categorizedProducts[item],categoryName: categories[item]) { returnCategory in
                            switch returnCategory {
                            case "Jewelery":
                                selectedIndex = 1
                            case "Electronics":
                                selectedIndex = 2
                            case "Men's Clothing":
                                selectedIndex = 3
                            case "Women's Clothing":
                                selectedIndex = 4
                            default:
                                selectedIndex = 0
                            }
                        }
                        
                    }
                }
            } else {
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        ProgressView("Preparing products")
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            Spacer()
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                SharedToolBarItem.SearchBar(text: $searchText)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                SharedToolBarItem.userLogo()
            }
            ToolbarItem(placement: .topBarTrailing) {
                SharedToolBarItem.CartView(showCartView: $showCartView, itemCount: $itemsSavedToCart.count)
            }
        }
        .fullScreenCover(isPresented: $showCartView, content: {
            CartView()
                .onDisappear {
                    DataPersistenceManager.shared.fetchCartItems { result in
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
        .task {
            APICaller.shared.getAllProducts { res in
                switch res {
                case .success(let products):
                        self.categorizedProducts[1] = products.filter { $0.category.lowercased() == categories[1].lowercased() }
                        self.categorizedProducts[2] = products.filter { $0.category.lowercased() == categories[2].lowercased() }
                        self.categorizedProducts[3] = products.filter { $0.category.lowercased() == categories[3].lowercased() }
                        self.categorizedProducts[4] = products.filter { $0.category.lowercased() == categories[4].lowercased() }
                        
                        print("""
                            \nJewelry: \(self.categorizedProducts[1].count)
                            \nElectronics: \(self.categorizedProducts[2].count)
                            \nMen's: \(self.categorizedProducts[3].count)
                            \nWomen's: \(self.categorizedProducts[4].count)
                            """)
                    isFetching = false
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
        .onAppear {
            DataPersistenceManager.shared.fetchCartItems { result in
                switch result {
                case .success(let cartItems):
                    itemsSavedToCart = cartItems
                case .failure(let failure):
                    print("Failed to fetch cart items")
                }
            }
        }
    }
}

struct TagLineView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Discover Your \nUnseen ")
                    .font(.custom("PlayfairDisplay-Regular", size: 28))
                + Text("Passion")
                    .font(.custom("PlayfairDisplay-Bold", size: 35))
                Spacer()
            }
            .padding(.leading, 15)
        }
    }
}

struct CategoryView: View {
    let isActive: Bool
    let text: String
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 19))
                .fontWeight(.medium)
                .foregroundStyle(isActive ? .mint : .black.opacity(0.5) )
            
            if isActive {
                Color.purple
                    .frame(width: 15, height: 2)
                    .clipShape(Capsule())
            }
        }
        .padding(.trailing)
    }
}

struct ProductScrollView: View {
    let products: [Product]
    let categoryName: String
    var submitAction: (String) -> Void
    var body: some View {
        VStack {
            HStack {
                Text(categoryName)
                    .font(.custom("PlayFairDisplay-Bold", size: 20))
                    .padding(.leading, 10)
                Spacer()
                Button(action: {
                    print("selected \(categoryName)")
                    submitAction(categoryName)
                }, label: {
                    Text("See all")
                        .padding(.trailing, 10)
                })
            }
            .padding(.top, 10)
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 5) {
                    ForEach(0 ..< products.count, id: \.self) { item in
                        NavigationLink(destination: ProductDetailView(selectedProduct: products[item], recommendedProducts: products)) {
                            ProductCardView(product: products[item])
                                .padding(.horizontal, 5)
                        }
                    }
                }
            }
        }
    }
}

struct ProductCardView: View {
    let product: Product
    var body: some View {
        VStack {
            WebImage(url: URL(string: product.image))
                .resizable()
                .frame(width: 170, height: 170)
                .cornerRadius(10)
            Text(product.title)
                .font(.system(size: 15))
                .lineLimit(2)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                StarRatingView(rating: product.rating.rate)
                Spacer()
                Text(PriceFormatter.shared.format(price: product.price))
                    .font(.system(size: 13))
            }
        }
        .frame(width: 170)
        .padding(10)
        .background(Color.mint.opacity(0.2))
        .cornerRadius(10)
    }
}
