import SwiftUI

struct RegisterView: View {
    @State private var userName = ""
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var belt: BeltRank = .blanca
    @State private var degrees = 0
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // La tarjeta tiene tamaño fijo; solo el formulario scrollea dentro
        VStack(spacing: 16) {

            // Encabezado fijo
            VStack(spacing: 5) {
                Image("YouJitsuLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                Text("YouJitsu")
                    .font(.largeTitle.bold())
                Text("Regístrate para comenzar")
                    .font(.subheadline)
            }

            // Campos con scroll
            ScrollView {
                VStack(spacing: 16) {
                    // Nombres
                    fieldRow(icon: "person.fill") {
                        TextField("Nombre de usuario", text: $userName)
                            .textFieldStyle(.plain)
                            .textContentType(.givenName)
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                    }

                    // Apellidos
                    fieldRow(icon: "person.2.fill") {
                        TextField("Nombre completo", text: $fullName)
                            .textFieldStyle(.plain)
                            .textContentType(.familyName)
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                    }

                    // Correo
                    fieldRow(icon: "envelope.fill") {
                        TextField("Correo electrónico", text: $email)
                            .textFieldStyle(.plain)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                    }

                    // Teléfono
                    fieldRow(icon: "phone.fill") {
                        TextField("Número de teléfono", text: $phone)
                            .textFieldStyle(.plain)
                            #if os(iOS)
                            .keyboardType(.phonePad)
                            #endif
                    }

                    // Contraseña
                    fieldRow(icon: "lock.fill") {
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.plain)
                    }

                    // Cinta y grados
                    BeltSelectorView(belt: $belt, degrees: $degrees)
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)

            // Botón fijo
            if let error = auth.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
            Button {
                Task {
                    await auth.signUp(
                        userName: userName,
                        fullName: fullName,
                        email: email,
                        phone: phone,
                        password: password,
                        belt: belt.rawValue,
                        degrees: degrees
                    )
                }
            } label: {
                Group {
                    if auth.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Registrarme")
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        // Alto fijo: 78% de la pantalla
        .containerRelativeFrame(.vertical) { height, _ in height * 0.78 }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.50), radius: 20, y: 10)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("Background1")
                .resizable()
                .scaledToFill()
                .blur(radius: 10, opaque: true)
                .ignoresSafeArea()
        }
        .onChange(of: auth.didRegister) { _, registered in
            if registered { dismiss() }
        }
        .onAppear {
            auth.errorMessage = nil
            auth.didRegister = false
        }
    }

    // Fila reutilizable: ícono + contenido
    private func fieldRow<Content: View>(
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            content()
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(auth.isLoading)
    }
}

#Preview {
    RegisterView()
        .environment(AuthManager())
}
