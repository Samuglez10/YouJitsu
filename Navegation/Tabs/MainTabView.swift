import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            TrainingView()
                .tabItem { Label("Entrenar", systemImage: "dumbbell.fill") }

            SearchView()    
                .tabItem { Label("Buscar", systemImage: "magnifyingglass") }

            NotificationView()
                .tabItem { Label("Avisos", systemImage: "bell.fill") }

            ProfileView()
                .tabItem { Label("Perfil", systemImage: "figure.martial.arts") }
        }
        .tint(.red)
    }
}
