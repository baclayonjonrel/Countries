//
//  FavoriteItemModel.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/21/24.
//

import Foundation

struct FavoriteItem: Codable {
    let id: Int
    let title: String
    let price: Decimal
    let description: String
    let category: String
    let image: String
    let rate: Double
    let count: Int
}
