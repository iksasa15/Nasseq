import SwiftUI

struct SavedView: View {
    @StateObject private var catalog = ProductCatalog()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var formationManager = FormationManager()
    
    @State private var selectedTab: SavedTab = .formations
    @State private var selectedProduct: Product? = nil
    @State private var navigateToProductDetail: Bool = false
    @State private var selectedFormation: FormationSnapshot? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var formationToDelete: FormationSnapshot? = nil
    
    enum SavedTab {
        case formations
        case favorites
    }
    
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
                
                VStack(spacing: 0) {
                    // Tab Selector
                    HStack(spacing: Spacing.md) {
                        // Formations Tab
                        TabButton(
                            title: "التنسيقات",
                            subtitle: "Formations",
                            isSelected: selectedTab == .formations,
                            action: { selectedTab = .formations }
                        )
                        
                        // Favorites Tab
                        TabButton(
                            title: "المفضلة",
                            subtitle: "Favorites",
                            isSelected: selectedTab == .favorites,
                            action: { selectedTab = .favorites }
                        )
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    
                    // Content
                    if selectedTab == .formations {
                        formationsContent
                    } else {
                        favoritesContent
                    }
                }
            }
            .navigationTitle("المحفوظات")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if selectedTab == .favorites && !favoriteProducts.isEmpty {
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
            .alert("حذف التنسيق", isPresented: $showDeleteAlert) {
                Button("إلغاء", role: .cancel) {}
                Button("حذف", role: .destructive) {
                    if let formation = formationToDelete {
                        formationManager.deleteFormation(formation)
                    }
                }
            } message: {
                Text("هل تريد حذف هذا التنسيق؟")
            }
            .navigationDestination(isPresented: $navigateToProductDetail) {
                if let product = selectedProduct {
                    ProductDetailView(product: product)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - Formations Content
    private var formationsContent: some View {
        Group {
            if formationManager.formations.isEmpty {
                VStack(spacing: Spacing.lg) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("لا توجد تنسيقات محفوظة بعد")
                        .font(.nasseqHeadline)
                        .foregroundColor(.primary)
                    
                    Text("احفظ تنسيقاتك المفضلة من شاشة الـ AR")
                        .font(.nasseqBody)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                    
                    Text("لحفظه هنا AR انشئ تنسيق طاولة في عرض")
                        .font(.nasseqSmall)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        ForEach(formationManager.formations) { formation in
                            FormationCard(
                                formation: formation,
                                image: formationManager.image(for: formation),
                                onTap: {
                                    selectedFormation = formation
                                },
                                onDelete: {
                                    formationToDelete = formation
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(Spacing.md)
                }
            }
        }
    }
    
    // MARK: - Favorites Content
    private var favoritesContent: some View {
        Group {
            if favoriteProducts.isEmpty {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.nasseqBody)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.nasseqSmall)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(isSelected ? Color.nasseqTeal : Color.nasseqSecondaryBackground)
            .cornerRadius(CornerRadius.md)
        }
    }
}

#Preview {
    SavedView()
}
