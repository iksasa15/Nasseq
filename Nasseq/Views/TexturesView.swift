import SwiftUI
import PhotosUI

struct TexturesView: View {
    @StateObject private var textureManager = TextureManager()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showNameDialog = false
    @State private var textureName = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.nasseqBackground.ignoresSafeArea()
                
                if textureManager.textures.isEmpty {
                    emptyStateView
                } else {
                    textureGridView
                }
            }
            .navigationTitle("الخامات")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, isPresented: $showImagePicker)
            }
            .alert("اسم الخامة", isPresented: $showNameDialog) {
                TextField("أدخل اسم الخامة", text: $textureName)
                    .environment(\.layoutDirection, .rightToLeft)
                Button("إلغاء", role: .cancel) {
                    textureName = ""
                    selectedImage = nil
                }
                Button("حفظ") {
                    saveTexture()
                }
            } message: {
                Text("أدخل اسماً للخامة الجديدة")
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                showNameDialog = true
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 70))
                .foregroundColor(.nasseqTeal.opacity(0.5))
            
            Text("لا توجد خامات")
                .font(.nasseqTitle)
                .foregroundColor(.primary)
            
            Text("اضغط على + لإضافة خامة جديدة")
                .font(.nasseqBody)
                .foregroundColor(.secondary)
        }
    }
    
    private var textureGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(textureManager.textures) { texture in
                    TextureCard(
                        texture: texture,
                        textureManager: textureManager
                    )
                }
            }
            .padding()
        }
    }
    
    private var addButton: some View {
        Button {
            showImagePicker = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.nasseqTeal)
        }
    }
    
    private func saveTexture() {
        guard let image = selectedImage, !textureName.isEmpty else { return }
        
        textureManager.addTexture(image: image, displayName: textureName)
        
        textureName = ""
        selectedImage = nil
    }
}

struct TextureCard: View {
    let texture: TextureItem
    @ObservedObject var textureManager: TextureManager
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                if let image = textureManager.loadImage(for: texture) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                } else {
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 150)
                }
                
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            Text(texture.displayName)
                .font(.nasseqBody)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .background(Color.nasseqCardBackground)
        .cornerRadius(CornerRadius.lg)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .alert("حذف الخامة", isPresented: $showDeleteAlert) {
            Button("إلغاء", role: .cancel) {}
            Button("حذف", role: .destructive) {
                textureManager.deleteTexture(id: texture.id)
            }
        } message: {
            Text("هل تريد حذف \(texture.displayName)؟")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    TexturesView()
}
