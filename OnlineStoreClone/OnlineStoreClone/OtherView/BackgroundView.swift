//
//  BackgroundView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.purple, .clear]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}
