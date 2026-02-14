import SwiftUI

struct SavedFormationsView: View {
    @StateObject private var formationManager = FormationManager()
    @State private var selectedFormation: FormationSnapshot? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var formationToDelete: FormationSnapshot? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nasseqBackground.ignoresSafeArea()
                
                if formationManager.formations.isEmpty {
                    // Empty state
                    VStack(spacing: Spacing.lg) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("لا توجد تنسيقات محفوظة")
                            .font(.nasseqHeadline)
                            .foregroundColor(.primary)
                        
                        Text("احفظ تنسيقاتك المفضلة من شاشة الـ AR")
                            .font(.nasseqBody)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.xl)
                    }
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
            .navigationTitle("التنسيقات المحفوظة")
            .navigationBarTitleDisplayMode(.large)
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
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Formation Card
struct FormationCard: View {
    let formation: FormationSnapshot
    let image: UIImage?
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Formation Image
            ZStack(alignment: .topTrailing) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(CornerRadius.md)
                } else {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(Color.nasseqSecondaryBackground)
                        .frame(height: 150)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        }
                }
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(Spacing.sm)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(Spacing.sm)
            }
            
            // Formation Name
            Text(formation.name)
                .font(.nasseqBody)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .environment(\.layoutDirection, .rightToLeft)
            
            // Date
            Text(formation.date, style: .date)
                .font(.nasseqSmall)
                .foregroundColor(.secondary)
            
            // Item count
            HStack(spacing: Spacing.xs) {
                Image(systemName: "cube.box")
                    .font(.system(size: 12))
                Text("\(formation.products.count) قطعة")
                    .font(.nasseqSmall)
            }
            .foregroundColor(.nasseqTeal)
        }
        .padding(Spacing.md)
        .background(Color.nasseqBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .stroke(Color.nasseqTeal.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    SavedFormationsView()
}
