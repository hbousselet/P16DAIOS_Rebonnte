import SwiftUI

struct AisleListView: View {
    @ObservedObject var viewModel = MedicineStockViewModel()

    var body: some View {
        NavigationView {
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
        .onAppear {
            Task {
                await viewModel.fetchMedicines()
            }
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
    }
}
