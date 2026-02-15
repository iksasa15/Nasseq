import SwiftUI
import RealityKit

struct ARScreen: View {
    @StateObject private var arManager = ARManager()
    @StateObject private var catalog = ProductCatalog()
    @StateObject private var formationManager = FormationManager()
    @StateObject private var textureManager = TextureManager()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var selectedProduct: Product?
    
    @State private var currentProduct: Product?
    @State private var showSaveDialog = false
    @State private var formationName = ""
    @State private var showSaveSuccess = false
    @State private var showTexturePicker = false
    @State private var selectedTextureId: UUID?
    
    var body: some View {
        ZStack {
            ARViewContainer(arManager: arManager, currentProduct: $currentProduct)
                .edgesIgnoringSafeArea(.all)
            
            topBarView
            bottomControlsView
        }
        .onAppear(perform: setupInitialProduct)
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
    
    private var topBarView: some View {
        VStack {
            HStack {
                closeButton
                Spacer()
                textureButton
                saveButton
            }
            .padding()
            Spacer()
        }
    }
    
    private var closeButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
    
    private var textureButton: some View {
        Button {
            showTexturePicker.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "photo.on.rectangle")
                Text("الخامات")
                    .font(.nasseqBody)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(showTexturePicker ? Color.nasseqTealDark : Color.nasseqTeal)
            .cornerRadius(CornerRadius.xl)
        }
    }
    
    private var saveButton: some View {
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
    
    private var bottomControlsView: some View {
        VStack(spacing: 15) {
            Spacer()
            
            if showTexturePicker {
                texturePickerView
            }
            
            if let product = currentProduct {
                productNameView(product: product)
            }
            
            productSelectorView
        }
    }
    
    private var texturePickerView: some View {
        VStack(spacing: 12) {
            Text("اختر الخامة")
                .font(.nasseqHeadline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(textureManager.textures) { texture in
                        textureItemView(texture: texture)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(CornerRadius.lg)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private func textureItemView(texture: TextureItem) -> some View {
        Button {
            selectedTextureId = texture.id
            if let image = textureManager.loadImage(for: texture) {
                arManager.changeObjectTexture(to: texture.name, image: image)
            }
        } label: {
            VStack(spacing: 6) {
                if let uiImage = textureManager.loadImage(for: texture) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedTextureId == texture.id ? Color.white : Color.clear, lineWidth: 3)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .frame(width: 80, height: 80)
                }
                
                Text(texture.displayName)
                    .font(.nasseqCaption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    private func productNameView(product: Product) -> some View {
        Text(product.nameArabic)
            .font(.nasseqHeadline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(CornerRadius.xl)
            .environment(\.layoutDirection, .rightToLeft)
    }
    
    private var productSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(catalog.products) { product in
                    productItemView(product: product)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
    
    private func productItemView(product: Product) -> some View {
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
    
    private func setupInitialProduct() {
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
    
    private func saveFormation() {
        guard !formationName.isEmpty else { return }
        
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
