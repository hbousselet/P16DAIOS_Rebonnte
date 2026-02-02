import SwiftUI

struct MainTabView: View {
    @Environment(MedicineStockViewModel.self) private var medicineViewModel

    var body: some View {
        TabView {
            ZStack {
                if medicineViewModel.showLoading {
                    LoadingView()
                        .zIndex(1)
                }
                AisleListView()
                    .tabItem {
                        Image(systemName: "list.dash")
                        Text("Aisles")
                    }
            }

            ZStack {
                if medicineViewModel.showLoading {
                    LoadingView()
                        .zIndex(1)
                }
                AllMedicinesView()
                    .tabItem {
                        Image(systemName: "square.grid.2x2")
                        Text("All Medicines")
                    }
            }
        }
        .onAppear {
            Task(priority: .background) {
                await medicineViewModel.fetchMedicines()
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
