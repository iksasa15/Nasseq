import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arManager: ARManager
    @ObservedObject var modelLibrary: ModelLibrary
    
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
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let location = sender.location(in: arView)
            
            // Raycast to find a horizontal plane
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let result = results.first {
                // Determine which model to place
                let modelName = parent.modelLibrary.selectedModel?.filename ?? "cup" // Default or selected
                
                placeObject(named: modelName, at: result, in: arView)
            }
        }
        
        func placeObject(named modelName: String, at result: ARRaycastResult, in arView: ARView) {
            let anchor = AnchorEntity(raycastResult: result)
            
            // Try to load the model
            do {
                let model = try parent.modelLibrary.loadModel(named: modelName)
                
                // Enable gestures
                model.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .scale], for: model)
                
                anchor.addChild(model)
                arView.scene.addAnchor(anchor)
                
            } catch {
                print("Failed to load model: \(modelName). Using fallback box.")
                
                // Fallback: Place a simple box
                let mesh = MeshResource.generateBox(size: 0.1)
                let material = SimpleMaterial(color: .blue, isMetallic: true)
                let model = ModelEntity(mesh: mesh, materials: [material])
                
                model.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .scale], for: model)
                
                anchor.addChild(model)
                arView.scene.addAnchor(anchor)
            }
        }
    }
}
