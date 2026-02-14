import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
            
            // Favorites
            FavoritesView()
                .tabItem {
                    Label("المفضلة", systemImage: "heart.fill")
                }
            
            // Saved Formations
            SavedFormationsView()
                .tabItem {
                    Label("التنسيقات", systemImage: "photo.on.rectangle.angled")
                }
        }
        .accentColor(.nasseqTeal)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ContentView()
}
