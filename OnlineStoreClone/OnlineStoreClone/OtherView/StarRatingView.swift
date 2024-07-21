//
//  StarRatingView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5

    var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: determineStarType(index: index))
                    .frame(maxWidth: 5, maxHeight: 5)
                
                    .padding(.horizontal, 3)
                    .foregroundColor(Color.yellow)
            }
        }
    }

    private func determineStarType(index: Int) -> String {
        let fullStarThreshold = Int(rating)
        let remainder = rating - Double(fullStarThreshold)

        if index <= fullStarThreshold {
            return "star.fill"
        } else if index == fullStarThreshold + 1 && remainder >= 0.01 && remainder < 0.99 {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
}
