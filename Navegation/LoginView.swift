import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(AuthManager.self) private var auth

    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image("Background1")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10, opaque: true)
                        .ignoresSafeArea()
                }

            VStack(spacing: 8) {
                // Tarjeta del formulario
                VStack(spacing: 16) {
                    VStack(spacing: 5) {
                        Image("YouJitsuLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                        Text("YouJitsu")
                            .font(.largeTitle.bold())
                        Text("Inicia sesión para continuar")
                            .font(.subheadline)
                    }

                    // Mensaje de cuenta creada
                    if auth.didRegister {
                        Text("¡Cuenta creada! Inicia sesión para continuar.")
                            .font(.footnote)
                            .foregroundStyle(.green)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                        TextField("Correo electrónico", text: $email)
                            .textFieldStyle(.plain)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.secondary)
                        SecureField("Contraseña", text: $password)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Mensaje de error
                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            await auth.signIn(email: email, password: password)
                        }
                    } label: {
                        Group {
                            if auth.isLoading {
                                ProgressView().tint(.black)
                            } else {
                                Text("Iniciar sesión")
                            }
                        }
                    }
                    .disabled(auth.isLoading)
                    .padding(.top, 4)

                    // Enlace al registro
                    NavigationLink("¿No tienes cuenta? Regístrate") {
                        RegisterView()
                    }
                    .font(.footnote.bold())
                    .foregroundStyle(.red)
                }
                .padding(24)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.50), radius: 20, y: 10)
            }
            .padding(.horizontal, 24)
        }
        .onAppear { auth.errorMessage = nil }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environment(AuthManager())
}
