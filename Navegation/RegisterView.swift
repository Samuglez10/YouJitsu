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
    
    /// nil = todo bien. Si hay texto, es el error a mostrar.
    private var validationError: String? {
        let user = userName.trimmingCharacters(in: .whitespaces)
        let name = fullName.trimmingCharacters(in: .whitespaces)
        let mail = email.trimmingCharacters(in: .whitespaces)

        if user.isEmpty || name.isEmpty || mail.isEmpty || password.isEmpty {
            return "Completa todos los campos"
        }
        if user.count < 3 || user.count > 20 {
            return "El usuario debe tener entre 3 y 20 caracteres"
        }
        if user.range(of: "^[A-Za-z0-9._]+$", options: .regularExpression) == nil {
            return "El usuario solo puede tener letras, números, punto y guion bajo"
        }
        if !mail.contains("@") || !mail.contains(".") {
            return "Escribe un correo válido"
        }
        if password.count < 6 {
            return "La contraseña debe tener al menos 6 caracteres"
        }
        return nil
    }

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
                    // Nombres de usuario
                    fieldRow(icon: "person.fill") {
                        TextField("Nombre de usuario", text: $userName)
                            .textFieldStyle(.plain)
                            .textContentType(.username)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                    }

                    //Full name
                    fieldRow(icon: "person.2.fill") {
                        TextField("Nombre completo", text: $fullName)
                            .textFieldStyle(.plain)
                            .textContentType(.name)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
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
                if let validationError {
                        auth.errorMessage = validationError
                        return
                }
                Task {
                    await auth.signUp(
                        userName: userName.trimmingCharacters(in: .whitespaces),
                        fullName: fullName.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces),
                        phone: phone.trimmingCharacters(in: .whitespaces),
                        password: password,
                        belt: belt.rawValue,
                        degrees: degrees
                    )
                }
            } label: {
                Group {
                    if auth.isLoading {
                        ProgressView().tint(.black)
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
        .environment(\.colorScheme, .light)
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
