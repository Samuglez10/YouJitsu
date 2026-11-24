import SwiftUI
import Observation
import Supabase

@MainActor
@Observable
class AuthManager {
    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?
    var didRegister = false

    init() {
        Task {
            for await (_, session) in supabase.auth.authStateChanges {
                if let session, !session.isExpired {
                    isLoggedIn = true
                } else {
                    isLoggedIn = false
                }
            }
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        didRegister = false
        do {
            try await supabase.auth.signIn(email: email, password: password)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp(userName: String, fullName: String, email: String,
                phone: String, password: String,
                belt: String, degrees: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            // El trigger de SQL crea la fila en "profiles" con estos datos
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "user_name": .string(userName),
                    "full_name": .string(fullName),
                    "phone": .string(phone),
                    "belt": .string(belt),
                    "degrees": .integer(degrees)
                ]
            )
            // Si la confirmación de correo está apagada, Supabase abre sesión;
            // la cerramos para mandarlo al login como antes
            if response.session != nil {
                try await supabase.auth.signOut()
            }
            didRegister = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        Task { try? await supabase.auth.signOut() }
    }
}
