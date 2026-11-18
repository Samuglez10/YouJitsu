import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("¡Sesión iniciada!")
                .font(.title.bold())
                .navigationTitle("Inicio")
        }
    }
}

