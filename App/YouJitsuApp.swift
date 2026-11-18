import SwiftUI
import Firebase

@main struct MyApp: App {
    @State private var authManager: AuthManager
    init() {
        FirebaseApp.configure()
        _authManager = State(initialValue: AuthManager())
    }
        
    var body: some Scene {
        
        WindowGroup {
            RootView()
                .environment(authManager)
        }
    }
}
