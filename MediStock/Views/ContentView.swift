import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthentificationViewModel()
    @State private var medicineViewModel = MedicineStockViewModel()

    var body: some View {
        Group {
            if authViewModel.authService.user != nil {
                MainTabView()
                    .environment(medicineViewModel)
                    .environment(authViewModel)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.startListening()
        }
    }
}
