//
//  ProfileView.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/20/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImage

struct ProfileView: View {
    
    @State private var purchaseHistory: [CartItem] = [CartItem]()
    @State private var isFetching: Bool = true
    @ObservedObject var viewModel: LoginViewModel
    @State private var showLoading: Bool = false
    @State private var editName: Bool = false
    @State private var editBio: Bool = false
    @State private var editGender: Bool = false
    @State private var editBithday: Bool = false
    @StateObject private var genderSelection = GenderSelectionViewModel()
    @StateObject private var dateSelection = DateSelectionViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                ZStack {
                    NavigationLink {
                        EditProfilePicView(viewModel: viewModel)
                    } label: {
                        if let imageURL = viewModel.currentUser?.photoURL {
                            WebImage(url: imageURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(.circle)
                        } else {
                            Image(systemName: "person")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                                .clipShape(.circle)
                        }
                    }

                }
                
                Text(viewModel.currentUser?.displayName ?? "Not set")
                
                Text(viewModel.currentUser?.email ?? "")
                Divider()
                    .padding(.horizontal, 10)
                
                
                List {
                    Section {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(viewModel.currentUser?.displayName ?? "Set Now")
                            Button {
                                withAnimation {
                                    editName = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }

                        }
                        HStack {
                            Text("Bio")
                            Spacer()
                            Text("Set Now")
                            Button {
                                //ad bio to core data only
                                withAnimation {
                                    editBio = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                        HStack {
                            Text("Gender")
                            Spacer()
                            Text("Set Now")
                            Button {
                                // add gender for core data only
                                withAnimation {
                                    editGender = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                        HStack {
                            Text("Birthday")
                            Spacer()
                            Text("Set Now")
                            Button {
                                //add birthday for core data only
                                withAnimation {
                                    editBithday = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                        }
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(viewModel.currentUser?.email ?? "")
                        }
                    } header: {
                        Text("Personal information")
                    }
                    Section {
                        if !isFetching {
                            if !purchaseHistory.isEmpty {
                                ScrollView {
                                    ForEach(purchaseHistory.indices, id: \.self) { item in
                                        HStack {
                                            WebImage(url: URL(string: purchaseHistory[item].image))
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                            VStack {
                                                Text(purchaseHistory[item].title)
                                                    .font(.system(size: 10))
                                                    .multilineTextAlignment(.leading)
                                                Text(PriceFormatter.shared.format(price: purchaseHistory[item].price))
                                                    .font(.system(size: 10))
                                                    .multilineTextAlignment(.leading)
                                            }
                                            Spacer()
                                            Text("Quantity: \(purchaseHistory[item].quantity ?? 1)")
                                                .font(.system(size: 10))
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                }
                            } else {
                                Text("No Items")
                            }
                        } else {
                            ZStack {
                                Color.black.opacity(0.5)
                                    .edgesIgnoringSafeArea(.all)
                                ProgressView()
                                    .scaleEffect(2)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    } header: {
                        Text("Purchase History")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                
                Spacer()
                VStack {
                    Button(action: {
                        viewModel.signOut { result in
                            switch result {
                            case .success(let success):
                                print("logged out")
                            case .failure(let failure):
                                print("failed logging out: \(failure)")
                            }
                        }
                    }, label: {
                        Text("Log out")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                    })
                }
            }
            .padding(.top, 40)
            
            if editName {
                CustomAlertViewWithTextField(
                                title: "Edit Name",
                                placeHolder: "Enter New Name",
                                isPresenting: $editName) { nameInput in
                                    print(nameInput)
                                    editName = false
                                    showLoading = true
                                    viewModel.updateUserName(userName: nameInput) { result in
                                        switch result {
                                        case .success(let success):
                                            print("Edited successfully")
                                            showLoading = false
                                        case .failure(let failure):
                                            print("Failed editing")
                                            showLoading = false
                                        }
                                    }
                                }
            }
            
            if editBio {
                CustomAlertViewWithTextField(
                                title: "Edit Bio",
                                placeHolder: "Enter New Bio",
                                isPresenting: $editBio) { bioInput in
                                    print(bioInput)
                                    editBio = false
                                }
            }
            
            if editGender {
                CustomAlertViewWithRadioButton(
                                title: "Select Gender",
                                isPresenting: $editGender,
                                viewModel: genderSelection,
                                onSubmit: { gender in
                                    print(gender)
                                    editGender = false
                                }
                            )
            }
            
            if editBithday {
                CustomAlertViewWithDatePicker(
                                title: "Select Date",
                                isPresenting: $editBithday,
                                viewModel: dateSelection,
                                onSubmit: { formattedDate in
                                    print(formattedDate)
                                    editBithday = false
                                }
                            )
            }
            
            if showLoading {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .scaleEffect(2)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            
        }
        .onAppear {
            DataPersistenceManager.shared.fetchHistoryItems(userId: viewModel.currentUser?.uid ?? "") { result in
                switch result {
                case .success(let history):
                    purchaseHistory = history
                    isFetching = false
                    print("fetched purchased history \(purchaseHistory.count)")
                case .failure(let failure):
                    print("Failed: \(failure)")
                }
            }
        }
    }
}
