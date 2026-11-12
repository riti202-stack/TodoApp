import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.user != nil {
                TaskListView()
            } else {
                AuthView()
            }
        }
        .animation(.default, value: authVM.user?.uid)
    }
}
