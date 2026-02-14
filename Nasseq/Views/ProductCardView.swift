import SwiftUI

struct ProductCardView: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteTap: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Product Image/Icon
                ZStack(alignment: .topTrailing) {
                    // Placeholder for product thumbnail
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.nasseqSecondaryBackground)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(systemName: product.category.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.nasseqTeal.opacity(0.5))
                        }
                    
                    // Favorite button
                    Button(action: onFavoriteTap) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isFavorite ? .red : .gray)
                            .padding(Spacing.sm)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(Spacing.sm)
                }
                
                // Product Name (Arabic)
                Text(product.nameArabic)
                    .font(.nasseqBody)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .environment(\.layoutDirection, .rightToLeft)
                
                // Category
                Text(product.category.displayName)
                    .font(.nasseqSmall)
                    .foregroundColor(.secondary)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            .padding(Spacing.md)
            .background(Color.nasseqBackground)
            .cornerRadius(CornerRadius.lg)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .stroke(Color.nasseqTeal.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        ProductCardView(
            product: Product.samples[0],
            isFavorite: false,
            onFavoriteTap: {},
            onTap: {}
        )
        .frame(width: 180)
        
        ProductCardView(
            product: Product.samples[1],
            isFavorite: true,
            onFavoriteTap: {},
            onTap: {}
        )
        .frame(width: 180)
    }
    .padding()
}
