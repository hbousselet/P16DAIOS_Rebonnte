import SwiftUI

struct MedicineListView: View {
    @State var viewModel: MedicineStockViewModel

    @Environment(\.dismiss) var dismiss
    var aisle: String

    private var correspondingAisles: [Medicine] {
        viewModel.medicines.filter { $0.aisle == aisle }
    }

    var body: some View {
        List {
            ForEach(correspondingAisles, id: \.id) { medicine in
                let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id })

                NavigationLink(destination: MedicineDetailView(index: index, viewModel: viewModel)) { // ça casse ici
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
            if viewModel.medicines.filter({ $0.aisle == aisle }).isEmpty {
                dismiss()
            }
        }
    }

    private func removeMedicine(offsets: IndexSet) {
        offsets.forEach { index in
            let medicines = viewModel.medicines.filter { $0.aisle == aisle }
            guard let occurrence = viewModel.medicines.firstIndex(where: { $0.id == medicines[index].id }) else { return }
            let id = viewModel.medicines[occurrence].id
            Task(priority: .userInitiated) {
                await viewModel.deleteMedicines(id: id)
                viewModel.stopHistoryStream()
            }
        }
    }
}
