import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: ProfileViewModel
    private let original: UserProfile

    @State private var userName: String
    @State private var fullName: String
    @State private var bio: String
    @State private var discipline: String
    @State private var belt: BeltRank
    @State private var degrees: Int
    @State private var pickerItem: PhotosPickerItem?
    @State private var photoData: Data?

    init(profile: UserProfile, viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self.original = profile
        _userName = State(initialValue: profile.userName)
        _fullName = State(initialValue: profile.fullName)
        _bio = State(initialValue: profile.bio ?? "")
        _discipline = State(initialValue: profile.discipline ?? UserProfile.disciplineOptions[0])
        _belt = State(initialValue: profile.beltRank)
        _degrees = State(initialValue: min(profile.degrees, profile.beltRank.maxDegrees))
    }

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !userName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $pickerItem, matching: .images) { preview }
                        Spacer()
                    }
                }

                Section("Datos") {
                    TextField("Nombre", text: $fullName)
                    TextField("Usuario", text: $userName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Entrenamiento") {
                    Picker("Disciplina", selection: $discipline) {
                        ForEach(UserProfile.disciplineOptions, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section {
                    BeltSelectorView(belt: $belt, degrees: $degrees)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Editar perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Guardar") { Task { await save() } }
                            .disabled(!canSave)
                    }
                }
            }
            .onChange(of: pickerItem) { _, newItem in
                Task { await loadPhoto(newItem) }
            }
        }
    }

    private func save() async {
        var updated = original
        updated.fullName = fullName.trimmingCharacters(in: .whitespaces)
        updated.userName = userName.trimmingCharacters(in: .whitespaces).lowercased()
        updated.bio = bio
        updated.discipline = discipline
        updated.belt = belt.rawValue
        updated.degrees = degrees
        if await viewModel.save(updated, photoData: photoData) { dismiss() }
    }

    @ViewBuilder
    private var preview: some View {
        Group {
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image).resizable().scaledToFill()
            } else if let urlString = original.photoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { $0.resizable().scaledToFill() } placeholder: { ProgressView() }
            } else {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        photoData = image.jpegData(compressionQuality: 0.6)
    }
}
