import SwiftUI

struct AisleListView: View {
    @State var viewModel: MedicineStockViewModel
    @State var showNewStockPage: Bool = false
    @Environment(AuthentificationViewModel.self) private var authViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showLoading {
                    LoadingView()
                        .zIndex(1)
                }
                List {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(destination: MedicineListView(viewModel: viewModel, aisle: aisle)) {
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
                authViewModel.signOut()
            }) {
                Image(systemName: "person.crop.circle.fill.badge.minus")
            })
            .navigationDestination(isPresented: $showNewStockPage) {
                MedicineDetailView(viewModel: viewModel,
                                   isCreatingNewStock: true)
            }
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
