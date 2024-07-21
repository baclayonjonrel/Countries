//
//  APICaller.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import Foundation

enum APIError: Error {
    case UnExpectedResponse
}

class APICaller {
    static let shared = APICaller()
    
    func getAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/products/") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponce = response as? HTTPURLResponse, (200...299).contains(httpResponce.statusCode) else {
                completion(.failure(APIError.UnExpectedResponse))
                return
            }
            
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Product].self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
}
