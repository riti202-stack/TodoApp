import SwiftUI
import FirebaseCore

@main
struct TodoAppApp: App {
    @StateObject private var authVM: AuthViewModel

    init() {
        FirebaseApp.configure()
        _authVM = StateObject(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}
