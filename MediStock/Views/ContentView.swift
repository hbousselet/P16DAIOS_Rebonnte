import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State private var medicineViewModel = MedicineStockViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Group {
            if session.session != nil {
                MainTabView()
                    .environment(medicineViewModel)
            } else {
                LoginView()
            }
        }
        .onAppear {
            session.listen()
            medicineViewModel.session = session
        }
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }
}
