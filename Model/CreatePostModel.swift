import SwiftUI
import Observation

@MainActor
@Observable
final class CreatePostViewModel {
    var isPublishing = false
    var errorMessage: String?

    func publish(title: String, description: String, date: Date,
                 type: PostType, imageData: Data?) async -> Bool {
        isPublishing = true
        defer { isPublishing = false }
        do {
            try await PostService.shared.createPost(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date,
                type: type,
                imageData: imageData
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
