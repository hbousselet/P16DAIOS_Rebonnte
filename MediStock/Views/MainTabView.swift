import SwiftUI

struct MainTabView: View {
    @Environment(MedicineStockViewModel.self) private var medicineViewModel
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
        .onAppear {
            Task(priority: .userInitiated) {
                await medicineViewModel.fetchMedicines()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}
