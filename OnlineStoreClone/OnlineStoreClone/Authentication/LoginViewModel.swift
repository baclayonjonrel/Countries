//
//  LoginViewModel.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var currentUser: User? = nil

    init() {
        self.currentUser = Auth.auth().currentUser
    }

    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            print("Logged out")
            completion(.success(()))
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
            completion(.failure(signOutError))
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.currentUser = result?.user
                completion(.success(result?.user))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<User?, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.currentUser = result?.user
                completion(.success(result?.user))
            }
        }
    }
    
    func updateUserName(userName: String, completion: @escaping (Result<User?, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = userName
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Update profile error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let updatedUser = Auth.auth().currentUser
                self.currentUser = updatedUser
                completion(.success(updatedUser))
            }
        } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            completion(.failure(error))
        }
    }
    
    func updateEmail(newEmail: String, completion: @escaping (Result<User?, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                if let error = error {
                    print("Send email verification error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                completion(.success(user))
            }
        } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            completion(.failure(error))
        }
    }


    func updatePassword(newPassword: String, completion: @escaping (Result<User?, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    print("Update password error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                let updatedUser = Auth.auth().currentUser
                self.currentUser = updatedUser
                completion(.success(updatedUser))
            }
        } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            completion(.failure(error))
        }
    }
    
    func updateProfilePhoto(photoURL: URL, completion: @escaping (Result<User?, Error>) -> Void) {
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = photoURL
            
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Update profile photo error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
            
                let updatedUser = Auth.auth().currentUser
                completion(.success(updatedUser))
            }
        } else {
            let error = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            completion(.failure(error))
        }
    }
}
