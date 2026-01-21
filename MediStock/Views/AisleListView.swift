import SwiftUI

struct AisleListView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel


    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.aisles, id: \.self) { aisle in
                    NavigationLink(destination: MedicineListView(aisle: aisle)) {
                        Text(aisle)
                    }
                }
            }
            .navigationBarTitle("Aisles")
            .navigationBarItems(trailing: Button(action: {
                Task {
                    await viewModel.addRandomMedicine(user: "test_user") // Remplacez par l'utilisateur actuel
                }
            }) {
                Image(systemName: "plus")
            })
            .navigationBarItems(leading: Button(action: {
                //
            }) {
                Image(systemName: "person.crop.circle.fill.badge.minus")
            })
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
    }
}
