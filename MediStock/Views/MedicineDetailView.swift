import SwiftUI

struct MedicineDetailView: View {
    @State var medicine: Medicine
    @Environment(MedicineStockViewModel.self) private var viewModel
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(medicine.name)
                    .font(.largeTitle)
                    .padding(.top, 20)

                medicineNameSection
                medicineStockSection
                medicineAisleSection
                historySection
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Medicine Details", displayMode: .inline)
    }
}

extension MedicineDetailView {
    private var medicineNameSection: some View {
        VStack(alignment: .leading) {
            Text("Name")
                .font(.headline)
            TextField("Name", text: $medicine.name)
                .onSubmit {
                    Task(priority: .background) {
                        await viewModel.updateStock(by: 0, for: medicine, and: session.session?.uid ?? "")
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
                    Task(priority: .background) {
                        await viewModel.updateStock(by: -1, for: medicine, and: session.session?.uid ?? "")
                    }
                }) {
                    Image(systemName: "minus.circle")
                        .font(.title)
                        .foregroundColor(.red)
                }
                TextField("Stock", value: $medicine.stock, formatter: NumberFormatter())
                    .onSubmit {
                        Task(priority: .background) {
                            await viewModel.updateStock(by: 0, for: medicine, and: session.session?.uid ?? "")
                        }
                    }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 100)
                Button(action: {
                    Task(priority: .background) {
                        await viewModel.updateStock(by: 1, for: medicine, and: session.session?.uid ?? "")
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
                    Task(priority: .background) {
                        await viewModel.updateStock(by: 0, for: medicine, and: session.session?.uid ?? "")
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
            ForEach(viewModel.history.filter { $0.medicineId == medicine.id }, id: \.id) { entry in
                VStack(alignment: .leading, spacing: 5) {
                    Text(entry.action)
                        .font(.headline)
                    Text("User: \(entry.user)")
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
    }
}

struct MedicineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMedicine = Medicine(name: "Sample", stock: 10, aisle: "Aisle 1")
        let sampleViewModel = MedicineStockViewModel()
        MedicineDetailView(medicine: sampleMedicine).environmentObject(SessionStore())
    }
}
