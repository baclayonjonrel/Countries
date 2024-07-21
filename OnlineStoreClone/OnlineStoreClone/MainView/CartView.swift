//
//  CartView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isFetching: Bool = true
    @State private var addedToCarts: [CartItem] = [CartItem]()
    @State private var totalAmountToPay: Decimal = Decimal()
    @State private var showCheckoutView: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var showLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                        
                    }
                    .padding()
                    Spacer()
                }
                VStack {
                    if !isFetching {
                        if addedToCarts.count > 0 {
                            VStack {
                                List {
                                    Section {
                                        ForEach(addedToCarts.indices, id: \.self) { i in
                                            VStack {
                                                HStack {
                                                    WebImage(url: URL(string: addedToCarts[i].image))
                                                        .resizable()
                                                        .frame(width: 50, height: 50)
                                                    VStack (alignment: .leading) {
                                                        Text(addedToCarts[i].title)
                                                            .font(.system(size: 10))
                                                            .multilineTextAlignment(.leading)
                                                        Text(PriceFormatter.shared.format(price: addedToCarts[i].price))
                                                            .font(.system(size: 10))
                                                            .multilineTextAlignment(.leading)
                                                        
                                                    }
                                                    Spacer()
                                                    Text(" Quantity: \(addedToCarts[i].quantity ?? 1)")
                                                        .font(.system(size: 10))
                                                        .multilineTextAlignment(.trailing)
                                                        .padding()
                                                }
                                            }
                                        }
                                        .onDelete(perform: deleteItems)
                                    } header: {
                                        Text("Order details")
                                    }
                                    Section {
                                        HStack {
                                            Text("Total amount: ")
                                            Spacer()
                                            Text(PriceFormatter.shared.format(price: totalAmountToPay))
                                        }
                                    } header: {
                                        Text("Sub total")
                                    }
                                }
                                .ignoresSafeArea(edges: .horizontal)
                                
                            }
                            Button(action: {
                                showLoading = true
                                startCheckOut(cartItems: addedToCarts) { clientSecret in
                                    PaymentConfig.shared.paymentIntentClientSecret = clientSecret
                                    showConfirmation = true
                                    showLoading = false
                                }
                            }, label: {
                                Text("Chekout")
                            })
                            .buttonStyle(BorderedButtonStyle())
                        } else {
                            Text("No items added yet")
                        }
                        
                    } else {
                        ProgressView()
                    }
                    Spacer()
                }
                Spacer()
            }
            if showLoading {
                ProgressView()
            }
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Confirm checkout?"),
                message: Text("Total amount to pay: \(PriceFormatter.shared.format(price: totalAmountToPay))."),
                primaryButton: .default(Text("Yes"), action: {
                    showCheckoutView = true
                }),
                secondaryButton: .default(Text("No"))
            )
        }
        .fullScreenCover(isPresented: $showCheckoutView) {
            CheckOutView(checkoutItems: addedToCarts, totalPriceToPay: totalAmountToPay)
        }
        .task {
            DataPersistenceManager.shared.fetchCartItems { result in
                switch result {
                case .success(let products):
                    self.addedToCarts = products
                    self.isFetching = false
                    self.totalAmountToPay = calculateTotalAmount(cartItem: addedToCarts)
                    
                case .failure(let failure):
                    print("failed to fetch products")
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            if addedToCarts.count > 0 {
                let product = addedToCarts[index]
                DataPersistenceManager.shared.deleteCartItem(item: product) { result in
                    switch result {
                    case .success(let success):
                        print("item deleted")
                        addedToCarts.remove(atOffsets: offsets)
                        self.totalAmountToPay = calculateTotalAmount(cartItem: addedToCarts)
                    case .failure(let failure):
                        print("failed to delete")
                    }
                }
            }
        }
    }
    
    private func calculateTotalAmount(cartItem: [CartItem]) -> Decimal {
        guard !cartItem.isEmpty else {
            print("Cart is empty")
            return 0
        }
        
        let total = cartItem.reduce(Decimal(0)) { sum, item in
            let quantity = item.quantity ?? 1
            let price = item.price
            return sum + (price * Decimal(quantity))
        }
        
        return total
    }
    
    struct CartItemsWrapper: Codable {
        let items: [CartItem]
    }
    
    private func startCheckOut(cartItems: [CartItem], completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://ahead-foul-food.glitch.me/create-payment-intent") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let wrapper = CartItemsWrapper(items: cartItems)
        
        do {
            let jsonData = try JSONEncoder().encode(wrapper)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
            }
        } catch {
            print("Failed to encode cart items: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
            }
            
            if let error = error {
                print("Request error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                if let data = data {
                    let responseDataString = String(data: data, encoding: .utf8)
                    print("Response data: \(String(describing: responseDataString))")
                }
                print("Invalid response or status code")
                completion(nil)
                return
            }
            
            do {
                let clientSecretResponse = try JSONDecoder().decode(CheckoutIntentResponse.self, from: data)
                completion(clientSecretResponse.clientSecret)
            } catch {
                print("Failed to decode response: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
}
