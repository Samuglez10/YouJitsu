import SwiftUI

struct BeltSelectorView: View {
    @Binding var belt: BeltRank
    @Binding var degrees: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.martial.arts")
                    .foregroundStyle(.secondary)
                Text("Cinta y grados")
                    .foregroundStyle(.secondary)
            }

            // 1. Elegir el color de la cinta
            HStack(spacing: 14) {
                ForEach(BeltRank.allCases) { rank in
                    Circle()
                        .fill(rank.color)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .overlay(
                            Circle()
                                .stroke(Color.red, lineWidth: belt == rank ? 3 : 0)
                                .padding(-4)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if belt != rank {
                                    belt = rank
                                    degrees = 0
                                }
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)

            // 2. Cinta con sus grados
            HStack(spacing: 0) {
                Rectangle()
                    .fill(belt.color)

                ZStack {
                    Rectangle()
                        .fill(belt.barColor)

                    HStack(spacing: 0) {
                        ForEach(1...belt.maxDegrees, id: \.self) { i in
                            Rectangle()
                                .fill(i <= degrees ? Color.white : Color.gray.opacity(0.6))
                                .frame(width: 8)
                                .padding(.horizontal, 3)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        // Tocar el último grado activo lo apaga
                                        degrees = (degrees == i) ? i - 1 : i
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 6)
                }
                .frame(width: CGFloat(belt.maxDegrees) * 14 + 24)
            }
            .frame(height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )

            // 3. Resumen
            Text("Cinta \(belt.rawValue.lowercased()) · \(degrees) \(degrees == 1 ? "grado" : "grados")")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct BeltView: View {
    let belt: BeltRank
    let degrees: Int
    var height: CGFloat = 44

    var body: some View {
        let shown = min(max(degrees, 0), belt.maxDegrees)

        HStack(spacing: 0) {
            Rectangle().fill(belt.color)

            ZStack {
                Rectangle().fill(belt.barColor)

                HStack(spacing: 0) {
                    ForEach(1...belt.maxDegrees, id: \.self) { i in
                        Rectangle()
                            .fill(i <= shown ? Color.white : Color.gray.opacity(0.6))
                            .frame(width: 8)
                            .padding(.horizontal, 3)
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(width: CGFloat(belt.maxDegrees) * 14 + 24)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
        )
    }
}
