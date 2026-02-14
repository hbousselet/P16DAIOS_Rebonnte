import SwiftUI

struct MainTabView: View {
    @Environment(MedicineStockViewModel.self) private var medicineViewModel
    @Environment(AuthentificationViewModel.self) private var authViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            AisleListView(viewModel: medicineViewModel)
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Aisles")
                    }
                AllMedicinesView(viewModel: medicineViewModel)
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("All Medicines")
                    }
        }
        .task {
            medicineViewModel.user = authViewModel.authService.user
            Task(priority: .userInitiated) {
                await medicineViewModel.fetchMedicines()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}
