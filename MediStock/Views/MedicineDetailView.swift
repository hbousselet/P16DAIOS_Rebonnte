import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @State var viewModel: MedicineStockViewModel
    @State var isCreatingNewStock: Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(medicine.name)
                    .font(.largeTitle)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)
                medicineNameSection
                    .accessibilityElement(children: .combine)
                medicineStockSection
                    .accessibilityElement(children: .combine)
                medicineAisleSection
                    .accessibilityElement(children: .combine)
                if isCreatingNewStock {
                    createButton
                        .padding(.horizontal)
                } else {
                    historySection
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitle(isCreatingNewStock ? "Add stock" : "Medicine Details", displayMode: .inline)
        .customAlert(presentAlert: $viewModel.presentAlertDetailsView, alertMessage: viewModel.alertDetailsView, removeAlert: {
            viewModel.removeAlert()
        })
    }
}

extension MedicineDetailView {
    private var medicineNameSection: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)
            TextField("Name", text: $medicine.name)
                .onSubmit {
                    if !isCreatingNewStock {
                        Task(priority: .userInitiated) {
                            await viewModel.updateStock(by: 0, for: medicine)
                        }
                    }
                }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }

    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("Stock")
                .font(.headline)
            HStack {
                Button(action: {
                    if !isCreatingNewStock {
                        Task(priority: .userInitiated) {
                            await viewModel.updateStock(by: -1, for: medicine)
                        }
                    }
                    medicine.stock -= 1
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                TextField("Stock", value: $medicine.stock, formatter: NumberFormatter())
                    .onSubmit {
                        if !isCreatingNewStock {
                            Task(priority: .userInitiated) {
                                await viewModel.updateStock(by: 0, for: medicine)
                            }
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
                Button(action: {
                    if !isCreatingNewStock {
                        Task(priority: .userInitiated) {
                            await viewModel.updateStock(by: 1, for: medicine)
                        }
                    }
                    medicine.stock += 1
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 10)
        }
        .accessibilityRepresentation {
            Stepper("\(medicine.stock) stocks", value: $medicine.stock, in: 0...10000, step: 1)
                .padding(.horizontal)
        }
    }

    private var medicineAisleSection: some View {
        VStack(alignment: .leading) {
            Text("Aisle")
                .font(.headline)
            TextField("Aisle", text: $medicine.aisle)
                .onSubmit {
                    if !isCreatingNewStock {
                        Task(priority: .userInitiated) {
                            await viewModel.updateStock(by: 0, for: medicine)
                        }
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("History")
                .font(.headline)
                .padding(.top, 20)
            ForEach(viewModel.history
                .filter({ $0.medicineId == medicine.id })
                .sorted(by: { $0.timestamp > $1.timestamp})
                    , id: \.id) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.headline)
                    Text("User: \(entry.userEmail)")
                        .font(.subheadline)
                    Text("Date: \(entry.timestamp.formatted())")
                        .font(.subheadline)
                    Text("Details: \(entry.details)")
                        .font(.subheadline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 5)
            }
        }
        .padding(.horizontal)
        .onAppear {
            Task(priority: .userInitiated) {
                await viewModel.fetchHistory(for: medicine)
            }
        }
    }

    private var createButton: some View {
        Button(action: {
            Task(priority: .userInitiated) {
                if medicine.userId == "" {
                    guard let userId = (viewModel.user as? User)?.uid else { return }
                    medicine.userId = userId
                }
                let hasCreated = await viewModel.createStock(for: medicine)
                if hasCreated {
                    isCreatingNewStock.toggle()
                    dismiss()
                }
            }
        }) {
            Text("Create new stock")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
