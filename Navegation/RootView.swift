import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        if auth.isLoggedIn {
            MainTabView()
        } else {
            NavigationStack {
                LoginView()
            }
        }
    }
}
