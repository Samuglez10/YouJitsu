import Foundation
import FirebaseFirestore
import FirebaseStorage

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchProfile(uid: String) async throws -> UserProfile? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        guard snapshot.exists else { return nil }
        return try snapshot.data(as: UserProfile.self)
    }

    /// Actualiza solo los campos editables (no toca email, phone ni createdAt).
    func updateProfile(_ p: UserProfile, uid: String) async throws {
        var data: [String: Any] = [
            "userName": p.userName,
            "fullName": p.fullName,
            "belt": p.belt,
            "degrees": p.degrees
        ]
        if let v = p.bio { data["bio"] = v }
        if let v = p.discipline { data["discipline"] = v }
        if let v = p.photoURL { data["photoURL"] = v }
        try await db.collection("users").document(uid).setData(data, merge: true)
    }

    func uploadPhoto(_ data: Data, uid: String) async throws -> String {
        let ref = storage.reference().child("profile_photos/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        _ = try await ref.putDataAsync(data, metadata: metadata)
        return try await ref.downloadURL().absoluteString
    }
}
