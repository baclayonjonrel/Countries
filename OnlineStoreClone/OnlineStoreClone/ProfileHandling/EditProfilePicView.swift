//
//  EditProfilePicView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseAuth

struct EditProfilePicView: View {
    
    @State var imageURL: URL?
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var avatarUIImage: UIImage?  // Store UIImage for upload
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack {
            if let avatarImage = avatarImage {
                avatarImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
            } else if let imageURL = imageURL {
                WebImage(url: imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
            }
            
            PhotosPicker("Select Image", selection: $avatarItem, matching: .images)
                .padding()
            
            Button(action: {
                uploadImage()
            }, label: {
                Text("Upload Photo")
            })
        }
        .onChange(of: avatarItem) {
            Task {
                if let data = try? await avatarItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    avatarUIImage = uiImage
                    avatarImage = Image(uiImage: uiImage)
                } else {
                    print("Failed to load image")
                }
            }
        }
    }

    private func uploadImage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No user is signed in")
            return
        }

        guard let imageData = avatarUIImage?.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert UIImage to Data")
            return
        }

        let storageRef = Storage.storage().reference().child("profilePic/\(uid).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to retrieve download URL: \(error.localizedDescription)")
                    return
                }

                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }

                viewModel.updateProfilePhoto(photoURL: downloadURL) { result in
                    switch result {
                    case .success(let updatedUser):
                        if let updatedUser = updatedUser {
                            print("Profile photo updated successfully for user: \(updatedUser.uid)")
                        }
                    case .failure(let error):
                        print("Failed to update profile photo: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}


