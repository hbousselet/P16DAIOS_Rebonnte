import SwiftUI

struct MedicineListView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel
    @Environment(\.dismiss) var dismiss
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
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
            Task(priority: .background) {
                await viewModel.deleteMedicines(id: id)
                viewModel.stopHistoryStream()
            }
        }
    }
}

struct MedicineListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicineListView(aisle: "Aisle 1").environmentObject(SessionStore())
    }
}
