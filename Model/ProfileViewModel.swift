import SwiftUI
import Observation
import Supabase

@MainActor
@Observable
final class ProfileViewModel {
    var profile: UserProfile?
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var posts: [Post] = []

    private var uid: UUID? { supabase.auth.currentUser?.id }

    func load() async {
        guard let uid else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await ProfileService.shared.fetchProfile(uid: uid)
            if profile == nil { errorMessage = "No se encontró tu perfil" }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadPosts() async {
        guard let uid else { return }
        do {
            posts = try await PostService.shared.fetchPosts(of: uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ updated: UserProfile, photoData: Data?) async -> Bool {
        guard let uid else { return false }
        isSaving = true
        defer { isSaving = false }
        var toSave = updated
        do {
            if let photoData {
                toSave.photoURL = try await ProfileService.shared.uploadPhoto(photoData, uid: uid)
            }
            try await ProfileService.shared.updateProfile(toSave, uid: uid)
            profile = toSave
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
