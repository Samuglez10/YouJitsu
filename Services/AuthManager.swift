import SwiftUI
import Observation
import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
class AuthManager{
    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?
    var didRegister = false
    
    init(){
        // Si habia una sesion se mantiene
        isLoggedIn = Auth.auth().currentUser != nil
    }
    
    func signIn(email: String, password: String) async{
        isLoading = true
        defer { isLoading = false}
        didRegister = false
        do {
            try await Auth.auth().signIn(withEmail: email,password: password)
            isLoggedIn = true
            errorMessage = nil
        } catch{
            errorMessage = error.localizedDescription
        }
    }

    func signUp(userName: String, fullName: String, email: String,
                    phone: String, password: String,
                    belt: String, degrees: Int) async {
            isLoading = true
            defer { isLoading = false }
            do {
                // 1. Crear la cuenta en Authentication
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = result.user.uid

                // 2. Guardar los datos del atleta en Firestore
                try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData([
                        "userName": userName.trimmingCharacters(in: .whitespaces).lowercased(),
                        "fullName": fullName.trimmingCharacters(in: .whitespaces),
                        "email": email,
                        "phone": phone,
                        "belt": belt,
                        "degrees": degrees,
                        "createdAt": FieldValue.serverTimestamp()
                    ])
                print("Usuario guardado con UID:", uid)
                // Firebase abre sesión al crear la cuenta; la cerramos para mandarlo al login
                try Auth.auth().signOut()
                isLoggedIn = false
                didRegister = true
                errorMessage = nil
            } catch {
                print("Error al registrar:", error)
                errorMessage = error.localizedDescription
            }
        }
    
    func signOut() {
        try? Auth.auth().signOut()
        isLoggedIn = false
    }
}
