import Foundation
import SwiftUI
import Combine

struct TextureItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let displayName: String
    let imagePath: String
    
    init(id: UUID = UUID(), name: String, displayName: String, imagePath: String = "") {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.imagePath = imagePath
    }
}

class TextureManager: ObservableObject {
    @Published var textures: [TextureItem] = []
    
    private let texturesDirectory: URL
    private let userDefaultsKey = "savedTextures"
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        texturesDirectory = documentsPath.appendingPathComponent("Textures", isDirectory: true)
        
        createTexturesDirectoryIfNeeded()
        loadTextures()
    }
    
    private func createTexturesDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: texturesDirectory.path) {
            try? FileManager.default.createDirectory(at: texturesDirectory, withIntermediateDirectories: true)
        }
    }
    
    func addTexture(image: UIImage, displayName: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            return
        }
        
        let textureId = UUID()
        let fileName = "\(textureId.uuidString).jpg"
        let fileURL = texturesDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            
            let textureItem = TextureItem(
                id: textureId,
                name: fileName,
                displayName: displayName,
                imagePath: fileURL.path
            )
            
            textures.append(textureItem)
            saveTexturesToUserDefaults()
            
            print("✅ Texture saved: \(displayName)")
        } catch {
            print("❌ Failed to save texture: \(error)")
        }
    }
    
    func deleteTexture(id: UUID) {
        guard let index = textures.firstIndex(where: { $0.id == id }) else { return }
        
        let texture = textures[index]
        let fileURL = URL(fileURLWithPath: texture.imagePath)
        
        try? FileManager.default.removeItem(at: fileURL)
        
        textures.remove(at: index)
        saveTexturesToUserDefaults()
        
        print("✅ Texture deleted: \(texture.displayName)")
    }
    
    func loadImage(for texture: TextureItem) -> UIImage? {
        let fileURL = URL(fileURLWithPath: texture.imagePath)
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    private func loadTextures() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let savedTextures = try? JSONDecoder().decode([TextureItem].self, from: data) else {
            return
        }
        
        textures = savedTextures.filter { texture in
            FileManager.default.fileExists(atPath: texture.imagePath)
        }
    }
    
    private func saveTexturesToUserDefaults() {
        if let data = try? JSONEncoder().encode(textures) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
