import SwiftUI

struct ProductGalleryView: View {
    @StateObject private var catalog = ProductCatalog()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    @State private var selectedCategory: ProductCategory? = nil
    @State private var searchText: String = ""
    @State private var selectedProduct: Product? = nil
    @State private var navigateToProductDetail: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var filteredProducts: [Product] {
        var products = catalog.products
        
        if let category = selectedCategory {
            products = products.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            products = catalog.search(query: searchText)
        }
        
        return products
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nasseqBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("ابحث عن المنتجات...", text: $searchText)
                            .font(.nasseqBody)
                            .environment(\.layoutDirection, .rightToLeft)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(Spacing.md)
                    .background(Color.nasseqSecondaryBackground)
                    .cornerRadius(CornerRadius.md)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.sm)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            CategoryChip(
                                title: "الكل",
                                icon: "square.grid.2x2",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(ProductCategory.allCases, id: \.self) { category in
                                CategoryChip(
                                    title: category.displayName,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.md)
                    }
                    
                    if catalog.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let error = catalog.error {
                        Spacer()
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.nasseqBody)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Button("إعادة المحاولة") {
                                catalog.loadProducts()
                            }
                            .font(.nasseqBody)
                            .foregroundColor(.white)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                            .background(Color.nasseqTeal)
                            .cornerRadius(CornerRadius.md)
                        }
                        .padding(Spacing.xl)
                        Spacer()
                    } else if filteredProducts.isEmpty {
                        Spacer()
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "tray")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("لا توجد منتجات")
                                .font(.nasseqHeadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: Spacing.md) {
                                ForEach(filteredProducts) { product in
                                    ProductCardView(
                                        product: product,
                                        isFavorite: favoritesManager.isFavorite(product.id),
                                        onFavoriteTap: {
                                            favoritesManager.toggleFavorite(product.id)
                                        },
                                        onTap: {
                                            selectedProduct = product
                                            navigateToProductDetail = true
                                        }
                                    )
                                }
                            }
                            .padding(Spacing.md)
                        }
                    }
                }
            }
            .navigationTitle("نسِّق")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $navigateToProductDetail) {
                if let product = selectedProduct {
                    ProductDetailView(product: product)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.nasseqCaption)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.nasseqTeal : Color.nasseqSecondaryBackground)
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(CornerRadius.xl)
            .shadow(color: isSelected ? Color.nasseqTeal.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    ProductGalleryView()
}
