import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Cerrar sesión") {
                    auth.signOut()
                }
            }
            .navigationTitle("Perfil")
        }
    }
}
