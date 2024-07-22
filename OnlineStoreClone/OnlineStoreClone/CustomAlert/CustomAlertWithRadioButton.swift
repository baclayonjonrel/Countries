//
//  CustomAlertWithRadioButton.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI

class GenderSelectionViewModel: ObservableObject {
    @Published var selectedGender: String = "Male"
}

struct CustomAlertViewWithRadioButton: View {
    @State var title: String
    @Binding var isPresenting: Bool
    @ObservedObject var viewModel: GenderSelectionViewModel
    var onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            if isPresenting {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                        .padding()

                    HStack {
                        RadioButtonField(
                            id: "Male",
                            label: "Male",
                            isMarked: viewModel.selectedGender == "Male" ? true : false,
                            callback: { selected in
                                viewModel.selectedGender = selected
                            }
                        )
                        RadioButtonField(
                            id: "Female",
                            label: "Female",
                            isMarked: viewModel.selectedGender == "Female" ? true : false,
                            callback: { selected in
                                viewModel.selectedGender = selected
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                    HStack(spacing: 0) {
                        Button(action: {
                            isPresenting = false
                        }) {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                        }
                        Divider()
                        Button(action: {
                            onSubmit(viewModel.selectedGender)
                        }) {
                            Text("Submit")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, 10)
                }
                .frame(width: 300, height: 200)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 20)
                .transition(.scale)
                .zIndex(1)
            }
        }
    }
}

struct RadioButtonField: View {
    let id: String
    let label: String
    let isMarked: Bool
    let callback: (String) -> Void

    var body: some View {
        Button(action: {
            self.callback(self.id)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.isMarked ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(self.isMarked ? Color.blue : Color.secondary)
                Text(label)
                    .font(Font.system(size: 14))
                Spacer()
            }
            .foregroundColor(Color.black)
        }
        .padding(.bottom, 10)
    }
}
