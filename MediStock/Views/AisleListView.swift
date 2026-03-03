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
                    .accessibilityLabel("Add new medicine")
                    .accessibilityAddTraits(.isButton)
            })
            .navigationBarItems(leading: Button(action: {
                authViewModel.signOut()
            }) {
                Image(systemName: "person.crop.circle.fill.badge.minus")
                    .accessibilityLabel("Signout")
                    .accessibilityAddTraits(.isButton)
            })
            .navigationDestination(isPresented: $showNewStockPage) {
                MedicineDetailView(medicine: Medicine.createNewStock(for: viewModel.user as? User), viewModel: viewModel, isCreatingNewStock: true)
            }
            .customAlert(presentAlert: $viewModel.presentAlertTabViews,
                         alertMessage: $viewModel.alertTabViews,
                         needSecondButton: true, secondButtonAction: {
                Task(priority: .userInitiated) {
                    await viewModel.fetchMedicines()
                }
            })
        }
    }
}
