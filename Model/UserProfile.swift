import Foundation
import FirebaseFirestore

/// Coincide con lo que AuthManager.signUp ya guarda en users/{uid}.
/// Los campos nuevos son opcionales para que los usuarios existentes sigan cargando.
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var userName: String
    var fullName: String
    var email: String
    var phone: String?
    var belt: String
    var degrees: Int
    var createdAt: Date?

    // Nuevos (se llenan desde "Editar perfil")
    var bio: String?
    var discipline: String?
    var photoURL: String?
    var academyId: String?


    /// La cinta guardada como texto, convertida a tu enum BeltRank.
    var beltRank: BeltRank {
        BeltRank(rawValue: belt) ?? .blanca
    }

    static let disciplineOptions = ["Jiu-Jitsu Brasileño", "No-Gi / Grappling", "MMA", "Otra"]
}
