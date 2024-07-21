//
//  DataPersistenceManager.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/21/24.
//

import Foundation
import CoreData

class DataPersistenceManager {

    enum DatabaseError: Error {
        case FailedToSaveData
        case FailedToFetchData
        case FailedToDeleteData
    }

    static let shared = DataPersistenceManager()

    private let cartContext = PersistenceController.shared.cartContainer.viewContext
    private let favoriteContext = PersistenceController.shared.favoriteContainer.viewContext
    private let historyContext = PersistenceController.shared.historyContainer.viewContext

    // Cart Items Management
    func addToCartItems(item: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        
        do {
            let results = try cartContext.fetch(fetchRequest)
            
            if let existingItem = results.first {
                // Update the quantity of the existing item
                existingItem.quantity = Int64(item.quantity ?? 0)
            } else {
                // Create a new item if it doesn't exist
                let newItem = CartItemEntity(context: cartContext)
                newItem.title = item.title
                newItem.quantity = Int64(item.quantity ?? 0)
                newItem.price = (item.price) as NSDecimalNumber
                newItem.image = item.image
                newItem.id = Int64(item.id)
                newItem.itemdescription = item.description
                newItem.category = item.category
                newItem.rate = Double(item.rate)
                newItem.count = Int64(item.count)
            }
            
            // Save the context
            try cartContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.FailedToSaveData))
        }
    }

    func fetchCartItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let request: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()

        do {
            let savedItems = try cartContext.fetch(request)
            let cartItems = savedItems.map { cartItemDB -> CartItem in
                let product = CartItem(
                    quantity: Int(cartItemDB.quantity),
                    id: Int(cartItemDB.id),
                    title: cartItemDB.title ?? "",
                    price: cartItemDB.price! as Decimal,
                    description: cartItemDB.itemdescription ?? "",
                    category: cartItemDB.category ?? "",
                    image: cartItemDB.image ?? "",
                    rate: cartItemDB.rate,
                    count: Int(cartItemDB.count)
                )
                return product
            }
            completion(.success(cartItems))
        } catch {
            completion(.failure(error))
        }
    }

    func deleteCartItem(item: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        
        do {
            let results = try cartContext.fetch(fetchRequest)
            if let itemToDelete = results.first {
                cartContext.delete(itemToDelete)
                try cartContext.save()
                completion(.success(()))
            } else {
                completion(.failure(DatabaseError.FailedToDeleteData))
            }
        } catch {
            completion(.failure(DatabaseError.FailedToDeleteData))
        }
    }

    func isItemInCart(id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let results = try cartContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch item: \(error)")
            return false
        }
    }
    
    func updateCartItemQuantity(id: Int, newQuantity: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<CartItemEntity> = CartItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try cartContext.fetch(fetchRequest)
            
            if let existingItem = results.first {
                // Update the quantity of the existing item
                existingItem.quantity = Int64(newQuantity) + existingItem.quantity
                
                // Save the context
                try cartContext.save()
                completion(.success(()))
            } else {
                completion(.failure(DatabaseError.FailedToFetchData))
            }
        } catch {
            completion(.failure(DatabaseError.FailedToFetchData))
        }
    }


    // Favorite Items Management
    func addToFavorites(item: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let newItem = FavoriteItemEntity(context: favoriteContext)
        newItem.title = item.title
        newItem.price = (item.price) as NSDecimalNumber
        newItem.image = item.image
        newItem.id = Int64(item.id)
        newItem.itemdescription = item.description
        newItem.category = item.category
        newItem.rate = Double(item.rating.rate)
        newItem.count = Int64(item.rating.count)

        do {
            try favoriteContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.FailedToSaveData))
        }
    }

    func fetchFavoriteItems(completion: @escaping (Result<[Product], Error>) -> Void) {
        let request: NSFetchRequest<FavoriteItemEntity> = FavoriteItemEntity.fetchRequest()

        do {
            let savedItems = try favoriteContext.fetch(request)
            let favoriteItems = savedItems.map { favoriteItemDB -> Product in
                return Product(
                    id: Int(favoriteItemDB.id),
                    title: favoriteItemDB.title ?? "",
                    price: favoriteItemDB.price! as Decimal,
                    description: favoriteItemDB.itemdescription ?? "",
                    category: favoriteItemDB.category ?? "",
                    image: favoriteItemDB.image ?? "",
                    rating: Rating(rate: favoriteItemDB.rate, count: Int(favoriteItemDB.count))
                )
            }
            completion(.success(favoriteItems))
        } catch {
            completion(.failure(error))
        }
    }

    func deleteFavoriteItem(item: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<FavoriteItemEntity> = FavoriteItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        
        do {
            let results = try favoriteContext.fetch(fetchRequest)
            if let itemToDelete = results.first {
                favoriteContext.delete(itemToDelete)
                try favoriteContext.save()
                completion(.success(()))
            } else {
                completion(.failure(DatabaseError.FailedToDeleteData))
            }
        } catch {
            completion(.failure(DatabaseError.FailedToDeleteData))
        }
    }


    func isItemInFavorites(id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteItemEntity> = FavoriteItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let results = try favoriteContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch item: \(error)")
            return false
        }
    }
    
    
    //Purchase History
    func addToHistory(item: CartItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<HistoryEntity> = HistoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        
        do {
            let results = try historyContext.fetch(fetchRequest)
            
            if let existingItem = results.first {
                existingItem.quantity = Int64(item.quantity ?? 0)
            } else {
                let newItem = HistoryEntity(context: historyContext)
                newItem.title = item.title
                newItem.quantity = Int64(item.quantity ?? 0)
                newItem.price = (item.price) as NSDecimalNumber
                newItem.image = item.image
                newItem.id = Int64(item.id)
                newItem.itemdescription = item.description
                newItem.category = item.category
                newItem.rate = Double(item.rate)
                newItem.count = Int64(item.count)
            }
            
            try historyContext.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.FailedToSaveData))
        }
    }

    func fetchHistoryItems(completion: @escaping (Result<[CartItem], Error>) -> Void) {
        let request: NSFetchRequest<HistoryEntity> = HistoryEntity.fetchRequest()

        do {
            let savedItems = try historyContext.fetch(request)
            let cartItems = savedItems.map { cartItemDB -> CartItem in
                let product = CartItem(
                    quantity: Int(cartItemDB.quantity),
                    id: Int(cartItemDB.id),
                    title: cartItemDB.title ?? "",
                    price: cartItemDB.price! as Decimal,
                    description: cartItemDB.itemdescription ?? "",
                    category: cartItemDB.category ?? "",
                    image: cartItemDB.image ?? "",
                    rate: cartItemDB.rate,
                    count: Int(cartItemDB.count)
                )
                return product
            }
            completion(.success(cartItems))
        } catch {
            completion(.failure(error))
        }
    }
    
    func isItemInHistory(id: Int64) -> Bool {
        let fetchRequest: NSFetchRequest<HistoryEntity> = HistoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let results = try historyContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch item: \(error)")
            return false
        }
    }
    
    func updateHistorytemQuantity(id: Int, newQuantity: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<HistoryEntity> = HistoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try historyContext.fetch(fetchRequest)
            
            if let existingItem = results.first {
                existingItem.quantity = Int64(newQuantity) + existingItem.quantity
                
                try historyContext.save()
                completion(.success(()))
            } else {
                completion(.failure(DatabaseError.FailedToFetchData))
            }
        } catch {
            completion(.failure(DatabaseError.FailedToFetchData))
        }
    }
    
}


struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    let cartContainer: NSPersistentContainer
    let favoriteContainer: NSPersistentContainer
    let historyContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        cartContainer = NSPersistentContainer(name: "CartItemDataModel")
        favoriteContainer = NSPersistentContainer(name: "FavoriteItemDataModel")
        historyContainer = NSPersistentContainer(name: "PurchaseHistoryDataModel")

        if inMemory {
            cartContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            favoriteContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            historyContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        [cartContainer, favoriteContainer, historyContainer].forEach { container in
            container.loadPersistentStores { storeDescription, error in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
}
