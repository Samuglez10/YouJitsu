import Foundation
import Supabase

final class PostService {
    static let shared = PostService()
    private init() {}

    /// Lo que se manda al crear. id, author_id y created_at los pone la base de datos.
    private struct NewPost: Encodable {
        let title: String
        let description: String
        let date: Date
        let type: String
        let media_url: String?
    }

    func createPost(title: String, description: String, date: Date,
                    type: PostType, imageData: Data?) async throws {
        guard let uid = supabase.auth.currentUser?.id else { return }

        var mediaURL: String?
        if let imageData {
            let path = "\(uid.uuidString.lowercased())/\(UUID().uuidString).jpg"
            try await supabase.storage
                .from("posts")
                .upload(path, data: imageData,
                        options: FileOptions(contentType: "image/jpeg"))
            mediaURL = try supabase.storage.from("posts").getPublicURL(path: path).absoluteString
        }

        let post = NewPost(title: title, description: description, date: date,
                           type: type.rawValue, media_url: mediaURL)
        try await supabase.from("posts").insert(post).execute()
    }

    func countPosts(of uid: UUID) async throws -> Int {
        try await supabase
            .from("posts")
            .select("*", head: true, count: .exact)
            .eq("author_id", value: uid)
            .execute()
            .count ?? 0
    }
    
    func fetchPosts(of uid: UUID) async throws -> [Post] {
        try await supabase
            .from("posts")
            .select()
            .eq("author_id", value: uid)
            .order("date", ascending: false)        // más recientes primero
            .order("created_at", ascending: false)  // desempate si tienen la misma fecha
            .execute()
            .value
    }
}
