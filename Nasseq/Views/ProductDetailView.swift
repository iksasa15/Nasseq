import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @State private var showARView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.nasseqBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Product Image/Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(Color.nasseqSecondaryBackground)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                Image(systemName: product.category.icon)
                                    .font(.system(size: 80))
                                    .foregroundColor(.nasseqTeal.opacity(0.5))
                            }
                    }
                    .frame(height: 300)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.md)
                    
                    // Product Information
                    VStack(alignment: .trailing, spacing: Spacing.md) {
                        // Arabic Name
                        Text(product.nameArabic)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.trailing)
                        
                        // English Name
                        Text(product.name)
                            .font(.nasseqHeadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                        
                        // Category
                        HStack(spacing: Spacing.xs) {
                            Text(product.category.displayName)
                                .font(.nasseqBody)
                                .foregroundColor(.nasseqTeal)
                            
                            Image(systemName: product.category.icon)
                                .font(.system(size: 16))
                                .foregroundColor(.nasseqTeal)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.nasseqTeal.opacity(0.1))
                        .cornerRadius(CornerRadius.md)
                        
                        if let descriptionArabic = product.descriptionArabic {
                            VStack(alignment: .trailing, spacing: Spacing.sm) {
                                Text("الوصف")
                                    .font(.nasseqHeadline)
                                    .foregroundColor(.primary)
                                
                                Text(descriptionArabic)
                                    .font(.nasseqBody)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.top, Spacing.md)
                        }
                        
                        VStack(alignment: .trailing, spacing: Spacing.sm) {
                            Text("التفاصيل")
                                .font(.nasseqHeadline)
                                .foregroundColor(.primary)
                            
                            DetailRow(
                                icon: "ruler",
                                label: "الحجم الحقيقي",
                                value: "\(String(format: "%.2f", product.realWorldScale)) متر"
                            )
                            
                            DetailRow(
                                icon: "cube.box",
                                label: "نوع النموذج",
                                value: "USDZ 3D"
                            )
                        }
                        .padding(.top, Spacing.md)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .environment(\.layoutDirection, .rightToLeft)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Bottom Action Buttons
            VStack {
                Spacer()
                
                HStack(spacing: Spacing.md) {
                    Button(action: {
                        favoritesManager.toggleFavorite(product.id)
                    }) {
                        Image(systemName: favoritesManager.isFavorite(product.id) ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(favoritesManager.isFavorite(product.id) ? .red : .gray)
                            .frame(width: 60, height: 60)
                            .background(Color.nasseqSecondaryBackground)
                            .cornerRadius(CornerRadius.md)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        showARView = true
                    }) {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "arkit")
                                .font(.system(size: 20))
                            
                            Text("تجربة في AR")
                                .font(.nasseqHeadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.nasseqTeal,
                                    Color.nasseqTealDark
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(CornerRadius.md)
                        .shadow(color: Color.nasseqTeal.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.nasseqBackground.opacity(0),
                            Color.nasseqBackground
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150)
                    .offset(y: -90)
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                }
            }
        }
        .fullScreenCover(isPresented: $showARView) {
            ARScreen(selectedProduct: product)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(value)
                .font(.nasseqBody)
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: Spacing.xs) {
                Text(label)
                    .font(.nasseqBody)
                    .foregroundColor(.secondary)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.nasseqTeal)
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product.samples[0])
    }
}
