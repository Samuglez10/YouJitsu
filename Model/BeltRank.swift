import SwiftUI

enum BeltRank: String, CaseIterable, Identifiable {
    case blanca = "Blanca"
    case azul = "Azul"
    case morada = "Morada"
    case cafe = "Café"
    case negra = "Negra"

    var id: String { rawValue }

    // Color del cuerpo de la cinta
    var color: Color {
        switch self {
        case .blanca: return .white
        case .azul:   return Color(red: 0.10, green: 0.30, blue: 0.80)
        case .morada: return Color(red: 0.45, green: 0.18, blue: 0.65)
        case .cafe:   return Color(red: 0.42, green: 0.26, blue: 0.14)
        case .negra:  return .black
        }
    }

    // Color de la barra donde van los grados (la negra lleva barra roja)
    var barColor: Color {
        self == .negra ? Color(red: 0.8, green: 0.05, blue: 0.05) : .black
    }

    // Grados máximos: 4 en las de color, 6 en la negra
    var maxDegrees: Int {
        self == .negra ? 6 : 4
    }
}
