import Foundation
import ARKit
import RealityKit
import Combine

class ARManager: NSObject, ObservableObject {
    var arView: ARView
    
    override init() {
        // Initialize arView first
        arView = ARView(frame: .zero)
        super.init()
        setupAR()
    }
    
    func setupAR() {
        // Check if AR is supported
        guard ARWorldTrackingConfiguration.isSupported else {
            print("ARWorldTracking is not supported on this device.")
            return
        }
        
        // precise make the delegate
        arView.session.delegate = self
        
        // CRITICAL: Check if Info.plist has the camera usage description
        // If this is missing, the app WILL CRASH immediately when ARKit tries to use the camera.
        if Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") == nil {
            print("⚠️ CRITICAL ERROR: 'Privacy - Camera Usage Description' is MISSING from Info.plist.")
            print("⚠️ The app will crash. You MUST add this key in Xcode project settings > Info tab.")
        }
        
        // Check Camera Permissions
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            print("Camera access authorized")
        case .denied:
            print("Camera access DENIED. User must enable it in Settings.")
            return // Don't try to run session
        case .restricted:
            print("Camera access RESTRICTED.")
            return // Don't try to run session
        case .notDetermined:
            print("Camera access not determined. ARKit will request it.")
        @unknown default:
            break
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        arView.session.run(config)
    }
}

extension ARManager: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session Failed: \(error.localizedDescription)")
        // In a real app, you'd show this error to the user via UI
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session Interruption Ended")
        // Reset tracking and/or relocalize
        arView.session.run(session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }

    
    func addCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
    }
    
    func placeObject(named modelName: String) {
        // 1. Get the center of the screen
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        // 2. Try to find a plane first (raycast)
        let results = arView.raycast(from: screenCenter, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            // Found a plane, place it there
            let anchor = AnchorEntity(raycastResult: result)
            loadAndAttachModel(named: modelName, to: anchor)
            arView.scene.addAnchor(anchor)
        } else {
            // 3. If no plane found, place it in front of the camera
            // Create a new anchor 0.5 meters in front of the camera
            let cameraAnchor = AnchorEntity(.camera)
            loadAndAttachModel(named: modelName, to: cameraAnchor)
            
            // Transform it to be 0.5m in front
            // Note: Camera anchor is attached to camera, so (0, 0, -0.5) is 0.5m in front
            // However, it's often better to place it in world space relative to camera transform
            // But AnchorEntity(.camera) simplifies this by tracking camera. 
            // We just need to offset the model.
            
            // Actually, a better approach for "floating" placement without tracking the camera 
            // (so it stays in place after placement) is to get current camera transform.
            if let cameraTransform = arView.session.currentFrame?.camera.transform {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.5 // 0.5 meters in front
                let transform = simd_mul(cameraTransform, translation)
                
                let anchor = AnchorEntity(world: transform)
                loadAndAttachModel(named: modelName, to: anchor)
                arView.scene.addAnchor(anchor)
            }
        }
    }
    
    private func loadAndAttachModel(named name: String, to anchor: AnchorEntity) {
        // Try to load the model
        // In a real app, you might want to do this asynchronously
        do {
            let modelEntity = try Entity.loadModel(named: name)
            
            // Add collision and interaction
            modelEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.rotation, .scale, .translation], for: modelEntity)
            
            anchor.addChild(modelEntity)
            
        } catch {
            print("Could not load model \(name): \(error). Using fallback.")
            
            // Fallback: Blue box
            let mesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            modelEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.rotation, .scale, .translation], for: modelEntity)
            
            anchor.addChild(modelEntity)
        }
    }
}
