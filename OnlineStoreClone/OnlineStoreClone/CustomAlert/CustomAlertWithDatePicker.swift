//
//  CustomAlertWithDatePicker.swift
//  OnlineStoreClone
//
//  Created by Jonrel Baclayon on 7/22/24.
//

import SwiftUI

class DateSelectionViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
}

struct CustomAlertViewWithDatePicker: View {
    var title: String
    @Binding var isPresenting: Bool
    @ObservedObject var viewModel: DateSelectionViewModel
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

                    DatePicker(
                        "Select Date",
                        selection: $viewModel.selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
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
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            let formattedDate = formatter.string(from: viewModel.selectedDate)
                            onSubmit(formattedDate)
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
                .frame(width: 300, height: 420)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 20)
                .transition(.scale)
                .zIndex(1)
            }
        }
    }
}
