import SwiftUI

struct MainTabView: View {
    @Environment(MedicineStockViewModel.self) private var medicineViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false

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
            Task(priority: .background) {
                await medicineViewModel.fetchMedicines()
            }
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
