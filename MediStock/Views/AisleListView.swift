import SwiftUI

struct AisleListView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel

    @State var showNewStockPage: Bool = false


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
                showNewStockPage.toggle()
            }) {
                Image(systemName: "plus")
            })
            .navigationBarItems(leading: Button(action: {
                //FIXME: NEED TO BE IMPLEMENTED
            }) {
                Image(systemName: "person.crop.circle.fill.badge.minus")
            })
            .navigationDestination(isPresented: $showNewStockPage) {
                MedicineDetailView(medicine: Medicine.createNewStock(for: viewModel.session?.session), isCreatingNewStock: true)
            }
        }
    }
}

struct AisleListView_Previews: PreviewProvider {
    static var previews: some View {
        AisleListView()
    }
}
