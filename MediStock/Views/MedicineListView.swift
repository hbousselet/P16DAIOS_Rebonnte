import SwiftUI

struct MedicineListView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    var aisle: String

    private var correspondingAisles: [Medicine] {
        viewModel.filterAisle(with: aisle)
    }

    var body: some View {
        List {
            ForEach(correspondingAisles, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicine: medicine, viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text(medicine.name)
                            .font(.headline)
                        Text("Stock: \(medicine.stock)")
                            .font(.subheadline)
                    }
                }
            }
            .onDelete(perform: removeMedicine)
        }
        .navigationBarTitle(aisle)
        .onChange(of: viewModel.medicines) {
            if correspondingAisles.isEmpty {
                dismiss()
            }
        }
    }

    private func removeMedicine(offsets: IndexSet) {
        offsets.forEach { index in
            Task(priority: .userInitiated) {
                await viewModel.deleteMedicines(for: index, and: aisle)
                viewModel.stopHistoryStream()
            }
        }
    }
}
