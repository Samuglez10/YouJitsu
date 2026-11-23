import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = CreatePostViewModel()
    @State private var title = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var type: PostType = .training
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && !viewModel.isPublishing
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Post") {
                    TextField("Título", text: $title)
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Detalles") {
                    Picker("Tipo", selection: $type) {
                        ForEach(PostType.allCases) { t in
                            Label(t.label, systemImage: t.icon).tag(t)
                        }
                    }
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                }

                Section("Contenido") {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        if let imageData, let ui = UIImage(data: imageData) {
                            Image(uiImage: ui)
                                .resizable().scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Label("Agregar foto", systemImage: "photo.on.rectangle")
                        }
                    }
                    if imageData != nil {
                        Button("Quitar foto", role: .destructive) {
                            imageData = nil; pickerItem = nil
                        }
                    }
                }
            }
            .navigationTitle("Nuevo post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isPublishing {
                        ProgressView()
                    } else {
                        Button("Publicar") { Task { await publish() } }
                            .disabled(!canPublish)
                    }
                }
            }
            .onChange(of: pickerItem) { _, item in
                Task { await loadPhoto(item) }
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
    }

    private func publish() async {
        if await viewModel.publish(title: title, description: description,
                                   date: date, type: type, imageData: imageData) {
            dismiss()
        }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        imageData = image.jpegData(compressionQuality: 0.7)
    }
}

