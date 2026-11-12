import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checklist")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                    .padding(.bottom, 8)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                if isSignUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }

                if let error = authVM.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        if isSignUp {
                            await authVM.signUp(email: email, password: password, confirm: confirmPassword)
                        } else {
                            await authVM.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    if authVM.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(authVM.isLoading)

                Button(isSignUp ? "Already have an account? Sign In"
                                : "Don't have an account? Sign Up") {
                    isSignUp.toggle()
                    authVM.errorMessage = nil
                }
                .font(.footnote)

                Spacer()
            }
            .padding()
            .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        }
    }
}
