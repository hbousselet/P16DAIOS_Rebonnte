import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @State var isCreatingNewStock: Bool = false
    @Environment(MedicineStockViewModel.self) private var viewModel
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            if viewModel.showLoading {
                LoadingView()
                    .zIndex(1)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(medicine.name)
                        .font(.largeTitle)
                        .padding(.top, 20)

                    medicineNameSection
                    medicineStockSection
                    medicineAisleSection
                    if isCreatingNewStock {
                        createButton
                            .padding(.horizontal)
                    } else {
                        historySection
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitle(isCreatingNewStock ? "Add stock" : "Medicine Details", displayMode: .inline)
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
                        Task(priority: .background) {
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
                        Task(priority: .background) {
                            await viewModel.updateStock(by: -1, for: medicine)
                        }
                    } else {
                        medicine.stock -= 1
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                TextField("Stock", value: $medicine.stock, formatter: NumberFormatter())
                    .onSubmit {
                        if !isCreatingNewStock {
                            Task(priority: .background) {
                                await viewModel.updateStock(by: 0, for: medicine)
                            }
                        }
                    }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
                Button(action: {
                    if !isCreatingNewStock {
                        Task(priority: .background) {
                            await viewModel.updateStock(by: 1, for: medicine)
                        }
                    } else {
                        medicine.stock += 1
                    }
                }) {
                    Image(systemName: "plus.circle")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal)
    }

    private var medicineAisleSection: some View {
        VStack(alignment: .leading) {
            Text("Aisle")
                .font(.headline)
            TextField("Aisle", text: $medicine.aisle)
                .onSubmit {
                    if !isCreatingNewStock {
                        Task(priority: .background) {
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
            Task(priority: .background) {
                await viewModel.fetchHistory(for: medicine)
            }
        }
    }

    private var createButton: some View {
        Button(action: {
            Task(priority: .background) {
                await viewModel.createStock(for: medicine)
                isCreatingNewStock.toggle()
                dismiss()
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

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1", userId: "cailloux")
        let sampleViewModel = MedicineStockViewModel()
        MedicineDetailView(medicine: sampleMedicine).environmentObject(SessionStore())
    }
}
