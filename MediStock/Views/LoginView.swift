import SwiftUI

struct LoginView: View {
    @State var authViewModel: AuthentificationViewModel

    var body: some View {
        VStack {
            Text("Authentication")
                .font(.title)
                .padding()
                .accessibilityAddTraits(.isHeader)
            Spacer()
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Email field")
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel("Password field")
                .padding()
            HStack {
                Button(action: {
                    Task(priority: .userInitiated) {
                        await authViewModel.signIn()
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Button(action: {
                    Task(priority: .userInitiated) {
                        await authViewModel.signUp()
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .padding()
        .customAlert(presentAlert: $authViewModel.alertIsPresented, alertMessage: $authViewModel.alert)
    }
}
