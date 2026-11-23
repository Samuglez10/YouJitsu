import Foundation

struct Post: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    var title: String
    var description: String
    var date: Date
    var type: String
    var mediaURL: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, description, date, type
        case authorId  = "author_id"
        case mediaURL  = "media_url"
        case createdAt = "created_at"
    }

    var postType: PostType { PostType(rawValue: type) ?? .training }
}
