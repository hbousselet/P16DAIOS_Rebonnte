import SwiftUI

struct LoginView: View {
    @State var authViewModel: AuthentificationViewModel

    var body: some View {
        VStack {
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                Task(priority: .userInitiated) {
                    await authViewModel.signIn()
                }
            }) {
                Text("Login")
            }
            Button(action: {
                Task(priority: .userInitiated) {
                    await authViewModel.signUp()
                }
            }) {
                Text("Sign Up")
            }
        }
        .padding()
        .customAlert(presentAlert: $authViewModel.alertIsPresented, alertMessage: authViewModel.alert)
    }
}
