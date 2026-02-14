import SwiftUI

struct FavoritesView: View {
    @StateObject private var catalog = ProductCatalog()
    @StateObject private var favoritesManager = FavoritesManager()
    
    @State private var selectedProduct: Product? = nil
    @State private var showARView: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var favoriteProducts: [Product] {
        favoritesManager.favoriteProducts(from: catalog.products)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nasseqBackground.ignoresSafeArea()
                
                if favoriteProducts.isEmpty {
                    // Empty state
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد مفضلات")
                            .font(.nasseqHeadline)
                            .foregroundColor(.primary)
                        
                        Text("اضغط على القلب في المنتجات لإضافتها هنا")
                            .font(.nasseqBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: Spacing.md) {
                            ForEach(favoriteProducts) { product in
                                ProductCardView(
                                    product: product,
                                    isFavorite: true,
                                    onFavoriteTap: {
                                        favoritesManager.toggleFavorite(product.id)
                                    },
                                    onTap: {
                                        selectedProduct = product
                                        showARView = true
                                    }
                                )
                            }
                        }
                        .padding(Spacing.md)
                    }
                }
            }
            .navigationTitle("المفضلة")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !favoriteProducts.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive) {
                            favoritesManager.clearAll()
                        } label: {
                            Text("مسح الكل")
                                .font(.nasseqBody)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showARView) {
                if let product = selectedProduct {
                    ARScreen(selectedProduct: product)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    FavoritesView()
}
