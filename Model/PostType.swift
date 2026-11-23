import Foundation

enum PostType: String, CaseIterable, Identifiable, Codable {
    case technique   = "technique"
    case training    = "training"
    case competition = "competition"
    case achievement = "achievement"

    var id: String { rawValue }

    /// Texto que se muestra en la app
    var label: String {
        switch self {
        case .technique:   return "Técnica"
        case .training:    return "Entrenamiento"
        case .competition: return "Competencia"
        case .achievement: return "Logro"
        }
    }

    var icon: String {
        switch self {
        case .technique:   return "figure.martial.arts"
        case .training:    return "dumbbell.fill"
        case .competition: return "trophy.fill"
        case .achievement: return "medal.fill"
        }
    }
}
