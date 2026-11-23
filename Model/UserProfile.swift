import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var userName: String
    var fullName: String
    var belt: String
    var degrees: Int
    var bio: String?
    var discipline: String?
    var photoURL: String?
    var academyId: UUID?
    var createdAt: Date?

    // Swift usa camelCase, la base de datos snake_case
    enum CodingKeys: String, CodingKey {
        case id, belt, degrees, bio, discipline
        case userName  = "user_name"
        case fullName  = "full_name"
        case photoURL  = "photo_url"
        case academyId = "academy_id"
        case createdAt = "created_at"
    }

    var beltRank: BeltRank {
        BeltRank(rawValue: belt) ?? .blanca
    }

    static let disciplineOptions = ["Jiu-Jitsu Brasileño", "No-Gi / Grappling", "MMA", "Otra"]
}
