import SwiftUI

struct MedicineListView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel
    var aisle: String

    var body: some View {
        List {
            ForEach(viewModel.medicines.filter { $0.aisle == aisle }, id: \.id) { medicine in
                NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
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
    }

    private func removeMedicine(offsets: IndexSet) {
        offsets.forEach { index in
            let id = viewModel.medicines[index].id
            Task(priority: .background) {
                await viewModel.deleteMedicines(id: id)
            }
        }
    }
}

struct MedicineListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicineListView(aisle: "Aisle 1").environmentObject(SessionStore())
    }
}
