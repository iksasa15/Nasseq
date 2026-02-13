import Foundation
import Combine
import RealityKit
import ARKit

struct ModelItem: Identifiable {
    var id: String { name }
    let name: String
    let filename: String
}

class ModelLibrary: ObservableObject {
    @Published var selectedModel: ModelItem?
    
    // Add your USDZ files to the project and list them here
    // For now, we use a placeholder name. 
    // You MUST add a file named "cup.usdz" or similar to your app bundle.
    let availableModels: [ModelItem] = [
        ModelItem(name: "Cup", filename: "cup"),
        ModelItem(name: "Chair", filename: "chair"),
        ModelItem(name: "Teapot", filename: "teapot")
    ]
    
    func loadModel(named filename: String) throws -> ModelEntity {
        let entity = try Entity.load(named: filename)
        if let modelEntity = entity as? ModelEntity {
            return modelEntity
        }
        
        let parent = ModelEntity()
        parent.addChild(entity)
        return parent
    }
}
