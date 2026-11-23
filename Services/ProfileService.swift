import Foundation
import Supabase

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    func fetchProfile(uid: UUID) async throws -> UserProfile? {
        let rows: [UserProfile] = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: uid)
            .execute()
            .value
        return rows.first
    }

    /// Solo los campos editables
    private struct ProfileUpdate: Encodable {
        let user_name: String
        let full_name: String
        let belt: String
        let degrees: Int
        let bio: String?
        let discipline: String?
        let photo_url: String?
    }

    func updateProfile(_ p: UserProfile, uid: UUID) async throws {
        let update = ProfileUpdate(
            user_name: p.userName,
            full_name: p.fullName,
            belt: p.belt,
            degrees: p.degrees,
            bio: p.bio,
            discipline: p.discipline,
            photo_url: p.photoURL
        )
        try await supabase
            .from("profiles")
            .update(update)
            .eq("id", value: uid)
            .execute()
    }

    func uploadPhoto(_ data: Data, uid: UUID) async throws -> String {
        // La carpeta debe ser el uid en minúsculas para pasar la política de Storage
        let path = "\(uid.uuidString.lowercased())/avatar.jpg"
        try await supabase.storage
            .from("avatars")
            .upload(path, data: data,
                    options: FileOptions(contentType: "image/jpeg", upsert: true))
        let url = try supabase.storage.from("avatars").getPublicURL(path: path)
        // ?v= evita que AsyncImage muestre la foto vieja guardada en caché
        return url.absoluteString + "?v=\(Int(Date().timeIntervalSince1970))"
    }
}
