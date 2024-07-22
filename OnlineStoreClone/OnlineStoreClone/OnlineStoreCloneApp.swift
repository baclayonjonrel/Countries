//
//  OnlineStoreCloneApp.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import Stripe
import Firebase

@main
struct OnlineStoreCloneApp: App {
    
    init() {
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "pk_test_51PbBFwC85PARelInwoG7Sj7fSCcsAOdX5weczQK0jfMuZLjNDiu1IBjRLjBIwa0kVQsHnh01osAUVoSA0Sn33Ekb00GsvyLzIM"
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
