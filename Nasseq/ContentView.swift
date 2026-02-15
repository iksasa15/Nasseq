import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Home
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
            
            // Browse Products
            ProductGalleryView()
                .tabItem {
                    Label("تصفح", systemImage: "square.grid.2x2")
                }
            
            // AR Camera - Direct Access
            ARCameraTab()
                .tabItem {
                    Label("الكاميرا", systemImage: "camera.fill")
                }
            
            // Textures Management
            TexturesView()
                .tabItem {
                    Label("الخامات", systemImage: "photo.on.rectangle")
                }
            
            // Saved (Favorites + Formations)
            SavedView()
                .tabItem {
                    Label("المحفوظات", systemImage: "bookmark.fill")
                }
        }
        .accentColor(.nasseqTeal)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ContentView()
}
