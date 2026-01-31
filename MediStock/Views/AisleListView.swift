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
                    guard let id = viewModel.currentUser else { return }
                    await viewModel.addRandomMedicine(user: id)
                }
            }) {
                Image(systemName: "plus")
            })
            .navigationBarItems(leading: Button(action: {
                //FIXME: NEED TO BE IMPLEMENTED
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
