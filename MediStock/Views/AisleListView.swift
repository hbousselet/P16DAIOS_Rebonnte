import SwiftUI

struct AisleListView: View {
    @State var viewModel: MedicineStockViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State var showNewStockPage: Bool = false


    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showLoading {
                    LoadingView()
                        .zIndex(1)
                }
                List {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(destination: MedicineListView(aisle: aisle)) {
                            Text(aisle)
                        }
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
                MedicineDetailView(medicine: Medicine.createNewStock(for: viewModel.session?.session), isCreatingNewStock: true, viewModel: viewModel)
            }
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .alert("Alert !", isPresented: $viewModel.presentAlertTabViews, actions: {
                Button("OK") { }
                Button("Retry fetch") {
                    Task(priority: .userInitiated) {
                        await viewModel.fetchMedicines()
                    }
                }
            }, message: {
                if let error = viewModel.alertTabViews {
                    Text(error)
                } else {
                    Text("Unknown Error")
                }
            })
        }
    }
}
