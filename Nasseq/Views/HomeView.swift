import SwiftUI

struct HomeView: View {
    @StateObject private var catalog = ProductCatalog()
    @StateObject private var favoritesManager = FavoritesManager()
    
    @State private var selectedProduct: Product? = nil
    @State private var showARView: Bool = false
    @State private var navigateToCatalog: Bool = false
    @State private var navigateToAR: Bool = false
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var featuredProducts: [Product] {
        // Show first 4 products as featured
        Array(catalog.products.prefix(4))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nasseqBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero Section
                        heroSection
                        
                        // Feature Cards
                        featureCardsSection
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.lg)
                        
                        // Featured Products
                        featuredProductsSection
                            .padding(.top, Spacing.xl)
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showARView) {
                if let product = selectedProduct {
                    ARScreen(selectedProduct: product)
                }
            }
            .navigationDestination(isPresented: $navigateToCatalog) {
                ProductGalleryView()
            }
            .navigationDestination(isPresented: $navigateToAR) {
                ARCameraTab()
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.nasseqTeal,
                    Color.nasseqTealDark
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: Spacing.md) {
                Spacer()
                
                // Logo
                Text("نسِّق")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // App Name
                Text("Nasseq")
                    .font(.nasseqHeadline)
                    .foregroundColor(.white.opacity(0.9))
                
                // Tagline
                Text("رتب طاولة طعامك بشكل مثالي")
                    .font(.nasseqBody)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                Spacer()
            }
            .padding(.vertical, Spacing.xl)
        }
        .frame(height: 280)
        .environment(\.layoutDirection, .rightToLeft)
    }
    
    // MARK: - Feature Cards Section
    private var featureCardsSection: some View {
        HStack(spacing: Spacing.md) {
            // AR View Card
            FeatureCard(
                title: "AR حرب عرض",
                subtitle: "شاهد على طاولتك",
                buttonText: "Try AR View",
                icon: "sparkles",
                iconColor: Color(red: 120/255, green: 200/255, blue: 180/255),
                action: {
                    navigateToAR = true
                }
            )
            
            // Browse Catalog Card
            FeatureCard(
                title: "تصفح الكتالوج",
                subtitle: "اكتشف أدوات المائدة",
                buttonText: "Browse Catalog",
                icon: "book.fill",
                iconColor: Color(red: 120/255, green: 200/255, blue: 180/255),
                action: {
                    navigateToCatalog = true
                }
            )
        }
    }
    
    // MARK: - Featured Products Section
    private var featuredProductsSection: some View {
        VStack(alignment: .trailing, spacing: Spacing.md) {
            // Section Header
            HStack {
                Button(action: {
                    navigateToCatalog = true
                }) {
                    Text("عرض الكل")
                        .font(.nasseqBody)
                        .foregroundColor(.nasseqTeal)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("المنتجات المميزة")
                        .font(.nasseqHeadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Featured Items")
                        .font(.nasseqSmall)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, Spacing.md)
            
            // Products Grid
            if catalog.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 200)
            } else if featuredProducts.isEmpty {
                Text("لا توجد منتجات مميزة")
                    .font(.nasseqBody)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            } else {
                LazyVGrid(columns: columns, spacing: Spacing.md) {
                    ForEach(featuredProducts) { product in
                        ProductCardView(
                            product: product,
                            isFavorite: favoritesManager.isFavorite(product.id),
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
                .padding(.horizontal, Spacing.md)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let title: String
    let subtitle: String
    let buttonText: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
                .padding(.top, Spacing.md)
                
                Spacer()
                
                // Text Content
                VStack(spacing: Spacing.xs) {
                    Text(title)
                        .font(.nasseqBody)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.nasseqSmall)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Button
                Text(buttonText)
                    .font(.nasseqCaption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(CornerRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color.nasseqSecondaryBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    HomeView()
}
