import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arManager: ARManager
    @Binding var currentProduct: Product?
    
    func makeUIView(context: Context) -> ARView {
        let arView = arManager.arView
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        // Add gesture recognizers
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update coordinator's current product
        context.coordinator.currentProduct = currentProduct
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        var currentProduct: Product?
        
        init(parent: ARViewContainer) {
            self.parent = parent
            self.currentProduct = parent.currentProduct
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let location = sender.location(in: arView)
            
            // Raycast to find a horizontal plane
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let result = results.first, let product = currentProduct {
                placeObject(product: product, at: result, in: arView)
            }
        }
        
        func placeObject(product: Product, at result: ARRaycastResult, in arView: ARView) {
            let anchor = AnchorEntity(raycastResult: result)
            
            // Try to load the model
            do {
                let modelEntity = try Entity.loadModel(named: product.modelFilename)
                
                // Apply real-world scale
                modelEntity.scale = SIMD3<Float>(repeating: product.realWorldScale)
                
                // Enable gestures
                modelEntity.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .scale], for: modelEntity)
                
                anchor.addChild(modelEntity)
                arView.scene.addAnchor(anchor)
                
            } catch {
                print("Failed to load model: \(product.modelFilename). Using fallback box.")
                
                // Fallback: Place a simple box with appropriate scale
                let mesh = MeshResource.generateBox(size: product.realWorldScale)
                let material = SimpleMaterial(color: .blue, isMetallic: true)
                let modelEntity = ModelEntity(mesh: mesh, materials: [material])
                
                modelEntity.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .scale], for: modelEntity)
                
                anchor.addChild(modelEntity)
                arView.scene.addAnchor(anchor)
            }
        }
    }
}
