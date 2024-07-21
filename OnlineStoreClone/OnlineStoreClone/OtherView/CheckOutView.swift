//
//  CheckOutView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/21/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Stripe

enum ActiveAlert {
    case confirmation, indicator
}

struct CheckOutView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var paymentMethodParams: STPPaymentMethodParams?
    let checkoutItems: [CartItem]
    let paymentGatewayController = PaymentGatewayController()
    let totalPriceToPay: Decimal
    @State private var showLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var activeAlert: ActiveAlert = .confirmation
    
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
                Text("Checkout")
                
                List {
                    Section {
                        ForEach(0..<checkoutItems.count) { i in
                            VStack {
                                Divider()
                                HStack {
                                    WebImage(url: URL(string: checkoutItems[i].image ?? ""))
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                    VStack {
                                        Text(checkoutItems[i].title ?? "")
                                            .font(.system(size: 10))
                                            .multilineTextAlignment(.leading)
                                        HStack {
                                            Text(PriceFormatter.shared.format(price: checkoutItems[i].price ))
                                                .font(.system(size: 10))
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                    Text(" Quantity: \(checkoutItems[i].quantity ?? 1)")
                                        .font(.system(size: 10))
                                        .multilineTextAlignment(.trailing)
                                        .padding()
                                }
                            }
                        }
                    } header: {
                        Text("Order details")
                    }
                    Section {
                        HStack {
                            Text("Amount to pay:")
                            Spacer()
                            Text(PriceFormatter.shared.format(price: totalPriceToPay))
                        }
                    } header: {
                        Text("Sub total")
                    }
                    Section {
                        STPPaymentCardTextField.Representable.init(paymentMethodParams: $paymentMethodParams)
                    } header: {
                        Text("Card details")
                    }
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 10)
                
                Spacer()
                
                Section {
                    Button {
                        showLoading = true
                        activeAlert = .confirmation
                        showAlert = true
                    } label: {
                        Text("Pay")
                    }
                }
                .padding(.bottom, 20)
            }
            if showLoading {
                ProgressView()
            }
        }
        .alert(isPresented: $showAlert) {
            switch activeAlert {
            case .confirmation:
                return Alert(
                    title: Text("Confirm payment?"),
                    message: Text("Total amount to pay: \(PriceFormatter.shared.format(price: totalPriceToPay))."),
                    primaryButton: .default(Text("Yes"), action: {
                        pay()
                    }),
                    secondaryButton: .default(Text("No"), action: {
                        showLoading = false
                    })
                )
            case .indicator:
                return Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func pay() {
        guard let clientSecret = PaymentConfig.shared.paymentIntentClientSecret else {return}
        
        let parmentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        parmentIntentParams.paymentMethodParams = paymentMethodParams
        
        paymentGatewayController.submitPayment(intent: parmentIntentParams) { status, intent, error in
            switch status {
            case .succeeded:
                alertTitle = "Success"
                alertMessage = "Payment successful"
            case .canceled:
                alertTitle = "Success"
                alertMessage = "Payment is canceled"
            case .failed:
                alertTitle = "Payment Failed"
                alertMessage = error?.localizedDescription ?? ""
            }
            activeAlert = .indicator
            showAlert = true
            showLoading = false
        }
        
    }
}
