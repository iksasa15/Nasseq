import Foundation
import UIKit
import RealityKit
import ARKit
import Combine

class FormationManager: ObservableObject {
    @Published var formations: [FormationSnapshot] = []
    
    private let userDefaultsKey = "nasseq_formations"
    private let documentsDirectory: URL
    private let formationsDirectory: URL
    
    init() {
        // Setup directories
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        formationsDirectory = documentsDirectory.appendingPathComponent("Formations", isDirectory: true)
        
        // Create formations directory if needed
        try? FileManager.default.createDirectory(at: formationsDirectory, withIntermediateDirectories: true)
        
        loadFormations()
    }
    
    // MARK: - Load Formations
    private func loadFormations() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([FormationSnapshot].self, from: data) {
            formations = decoded.sorted { $0.date > $1.date }
        }
    }
    
    // MARK: - Save Formations
    private func saveFormations() {
        if let encoded = try? JSONEncoder().encode(formations) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Save New Formation
    func saveFormation(
        name: String,
        image: UIImage,
        placedProducts: [PlacedProduct]
    ) -> FormationSnapshot? {
        // Generate unique filename
        let imageFilename = "\(UUID().uuidString).jpg"
        let imageURL = formationsDirectory.appendingPathComponent(imageFilename)
        
        // Save image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return nil
        }
        
        do {
            try imageData.write(to: imageURL)
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
        
        // Create formation
        let formation = FormationSnapshot(
            name: name,
            imagePath: imageFilename,
            products: placedProducts
        )
        
        formations.insert(formation, at: 0) // Add to beginning
        saveFormations()
        
        return formation
    }
    
    // MARK: - Delete Formation
    func deleteFormation(_ formation: FormationSnapshot) {
        // Delete image file
        let imageURL = formationsDirectory.appendingPathComponent(formation.imagePath)
        try? FileManager.default.removeItem(at: imageURL)
        
        // Remove from array
        formations.removeAll { $0.id == formation.id }
        saveFormations()
    }
    
    // MARK: - Get Image for Formation
    func image(for formation: FormationSnapshot) -> UIImage? {
        let imageURL = formationsDirectory.appendingPathComponent(formation.imagePath)
        guard let data = try? Data(contentsOf: imageURL) else { return nil }
        return UIImage(data: data)
    }
    
    // MARK: - Capture AR View
    static func captureARView(_ arView: ARView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(arView.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        arView.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Extract Placed Products from AR Scene
    static func extractPlacedProducts(from arView: ARView, catalog: ProductCatalog) -> [PlacedProduct] {
        var placedProducts: [PlacedProduct] = []
        
        // Iterate through all anchors in the scene
        for anchor in arView.scene.anchors {
            // Skip if it's not an AnchorEntity
            guard let anchorEntity = anchor as? AnchorEntity else { continue }
            
            // Get all model entities under this anchor
            for child in anchorEntity.children {
                guard let modelEntity = child as? ModelEntity else { continue }
                
                // Try to find matching product (you might want to tag entities with product IDs)
                // For now, we'll create a basic representation
                let placedProduct = PlacedProduct(
                    productId: UUID(), // TODO: Store actual product ID on entity
                    position: modelEntity.position,
                    rotation: modelEntity.orientation,
                    scale: modelEntity.scale
                )
                
                placedProducts.append(placedProduct)
            }
        }
        
        return placedProducts
    }
}
