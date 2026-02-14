import SwiftUI
import RealityKit

struct ARScreen: View {
    @StateObject private var arManager = ARManager()
    @StateObject private var catalog = ProductCatalog()
    @StateObject private var formationManager = FormationManager()
    
    @Environment(\.dismiss) private var dismiss
    
    // Selected product to place
    var selectedProduct: Product?
    
    @State private var currentProduct: Product?
    @State private var showSaveDialog = false
    @State private var formationName = ""
    @State private var showSaveSuccess = false
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(arManager: arManager, currentProduct: $currentProduct)
                .edgesIgnoringSafeArea(.all)
            
            // Top Bar
            VStack {
                HStack {
                    // Close button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Save formation button
                    Button {
                        showSaveDialog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "camera")
                            Text("حفظ")
                                .font(.nasseqBody)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.nasseqTeal)
                        .cornerRadius(CornerRadius.xl)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Bottom Product Selector
            VStack(spacing: 15) {
                Spacer()
                
                // Selected Product Name
                if let product = currentProduct {
                    Text(product.nameArabic)
                        .font(.nasseqHeadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(CornerRadius.xl)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                
                // Product Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(catalog.products) { product in
                            Button {
                                currentProduct = product
                                arManager.placeObject(
                                    named: product.modelFilename,
                                    scale: product.realWorldScale
                                )
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: product.category.icon)
                                        .font(.system(size: 28))
                                        .foregroundColor(currentProduct?.id == product.id ? .white : .nasseqTeal)
                                    
                                    Text(product.nameArabic)
                                        .font(.nasseqSmall)
                                        .foregroundColor(currentProduct?.id == product.id ? .white : .primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 70)
                                }
                                .padding(12)
                                .background {
                                    if currentProduct?.id == product.id {
                                        Color.nasseqTeal
                                    } else {
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                    }
                                }
                                .cornerRadius(CornerRadius.lg)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            print("🎥 ARScreen appeared")
            print("🎥 Selected product: \(selectedProduct?.nameArabic ?? "nil")")
            
            // Set initial product if provided
            if let product = selectedProduct {
                currentProduct = product
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    arManager.placeObject(
                        named: product.modelFilename,
                        scale: product.realWorldScale
                    )
                }
            } else if let firstProduct = catalog.products.first {
                currentProduct = firstProduct
            }
        }
        .alert("حفظ التنسيق", isPresented: $showSaveDialog) {
            TextField("اسم التنسيق", text: $formationName)
                .environment(\.layoutDirection, .rightToLeft)
            Button("إلغاء", role: .cancel) {
                formationName = ""
            }
            Button("حفظ") {
                saveFormation()
            }
        } message: {
            Text("أدخل اسماً لهذا التنسيق")
        }
        .alert("تم الحفظ!", isPresented: $showSaveSuccess) {
            Button("موافق", role: .cancel) {}
        } message: {
            Text("تم حفظ التنسيق بنجاح")
        }
    }
    
    private func saveFormation() {
        guard !formationName.isEmpty else { return }
        
        // Capture AR view
        if let image = FormationManager.captureARView(arManager.arView) {
            let placedProducts = FormationManager.extractPlacedProducts(
                from: arManager.arView,
                catalog: catalog
            )
            
            _ = formationManager.saveFormation(
                name: formationName,
                image: image,
                placedProducts: placedProducts
            )
            
            formationName = ""
            showSaveSuccess = true
        }
    }
}

#Preview {
    ARScreen()
}
