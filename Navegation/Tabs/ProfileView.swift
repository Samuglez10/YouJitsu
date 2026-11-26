import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var auth
    @State private var viewModel = ProfileViewModel()
    @State private var showEdit = false
    @State private var showNewPost = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.profile == nil {
                    ProgressView()
                } else if let profile = viewModel.profile {
                    content(profile)
                } else {
                    Text("No se pudo cargar el perfil").foregroundStyle(.secondary)
                    Button("Cerrar sesión", role: .destructive) { auth.signOut() }
                        .padding(.top, 8)
                }
            }
            .navigationTitle("Perfil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Editar") { showEdit = true }
                        .disabled(viewModel.profile == nil)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button { showNewPost = true } label: { Image(systemName: "plus") }
                        .disabled(viewModel.profile == nil)
                }
            }
            .sheet(isPresented: $showEdit) {
                if let profile = viewModel.profile {
                    EditProfileView(profile: profile, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showNewPost, onDismiss: {
                Task { await viewModel.loadPosts() }
            }) {
                CreatePostView()
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            await viewModel.load()
            await viewModel.loadPosts()
        }
    }

    @ViewBuilder
    private func content(_ p: UserProfile) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                avatar(p.photoURL)

                VStack(spacing: 4) {
                    Text(p.fullName.isEmpty ? "Tu nombre" : p.fullName)
                        .font(.title2.bold())
                    if !p.userName.isEmpty {
                        Text("@\(p.userName)").foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 5) {
                    if let d = p.discipline, !d.isEmpty {
                        chip(d, systemImage: "figure.martial.arts")
                    }
                    BeltView(belt: p.beltRank, degrees: p.degrees)
                }

                if let bio = p.bio, !bio.isEmpty {
                    Text(bio)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Estadísticas
                HStack {
                    stat("Posts", value: viewModel.posts.count)
                    Divider().frame(height: 32)
                    stat("Amigos", value: 0)
                }
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Publicaciones
                VStack(alignment: .leading, spacing: 12) {
                    Text("Publicaciones")
                        .font(.title3.bold())

                    if viewModel.posts.isEmpty {
                        ContentUnavailableView(
                            "Sin publicaciones",
                            systemImage: "square.and.pencil",
                            description: Text("Toca + para compartir tu primera técnica o entrenamiento.")
                        )
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.posts) { post in
                                PostCardView(post: post)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Button("Cerrar sesión", role: .destructive) { auth.signOut() }
                    .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.load()
            await viewModel.loadPosts()
        }
    }

    private func avatar(_ urlString: String?) -> some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { $0.resizable().scaledToFill() } placeholder: { ProgressView() }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
    }

    private func chip(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }

    private func stat(_ title: String, value: Int) -> some View {
        VStack {
            Text("\(value)").font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
