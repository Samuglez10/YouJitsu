import SwiftUI

struct PostCardView: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tipo + fecha
            HStack {
                Label(post.postType.label, systemImage: post.postType.icon)
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.12), in: Capsule())
                    .foregroundStyle(.red)

                Spacer()

                Text(post.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Título
            Text(post.title)
                .font(.headline)

            // Foto (si tiene)
            if let urlString = post.mediaURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .overlay(ProgressView())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Descripción (si tiene)
            if !post.description.isEmpty {
                Text(post.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
