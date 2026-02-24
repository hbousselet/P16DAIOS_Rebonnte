import SwiftUI

struct LoginView: View {
    @State var authViewModel: AuthentificationViewModel

    var body: some View {
        VStack {
            Text("Authentication")
                .font(.title)
                .padding()
                .accessibilityAddTraits(.isHeader)
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Email field")
                .padding()
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Password field")
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
