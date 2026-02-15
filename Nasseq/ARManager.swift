import Foundation
import ARKit
import RealityKit
import Combine

class ARManager: NSObject, ObservableObject {
    var arView: ARView
    
    override init() {
        arView = ARView(frame: .zero)
        super.init()
        setupAR()
    }
    
    func setupAR() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("ARWorldTracking is not supported on this device.")
            return
        }
        
        arView.session.delegate = self
        
        if Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") == nil {
            print("⚠️ CRITICAL ERROR: 'Privacy - Camera Usage Description' is MISSING from Info.plist.")
            print("⚠️ The app will crash. You MUST add this key in Xcode project settings > Info tab.")
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            print("Camera access authorized")
        case .denied:
            print("Camera access DENIED. User must enable it in Settings.")
            return
        case .restricted:
            print("Camera access RESTRICTED.")
            return
        case .notDetermined:
            print("Camera access not determined. ARKit will request it.")
        @unknown default:
            break
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        arView.session.run(config)
    }
}

extension ARManager: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR Session Failed: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR Session Interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR Session Interruption Ended")
        arView.session.run(session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }

    
    func addCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(coachingOverlay)
    }
    
    func placeObject(named modelName: String, scale: Float = 0.1) {
        let screenCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: screenCenter, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let result = results.first {
            let anchor = AnchorEntity(raycastResult: result)
            loadAndAttachModel(named: modelName, scale: scale, to: anchor)
            arView.scene.addAnchor(anchor)
        } else {
            if let cameraTransform = arView.session.currentFrame?.camera.transform {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.5
                let transform = simd_mul(cameraTransform, translation)
                
                let anchor = AnchorEntity(world: transform)
                loadAndAttachModel(named: modelName, scale: scale, to: anchor)
                arView.scene.addAnchor(anchor)
            }
        }
    }
    
    private func loadAndAttachModel(named name: String, scale: Float, to anchor: AnchorEntity) {
        print("🔍 Attempting to load model: \(name)")
        
        var modelEntity: ModelEntity?
        
        do {
            modelEntity = try Entity.loadModel(named: name)
            print("✅ Successfully loaded model using name: \(name)")
        } catch {
            print("⚠️ Method 1 failed: \(error)")
            
            do {
                modelEntity = try Entity.loadModel(named: "\(name).usdz")
                print("✅ Successfully loaded model with extension: \(name).usdz")
            } catch {
                print("⚠️ Method 2 failed: \(error)")
                
                if let url = Bundle.main.url(forResource: name, withExtension: "usdz") {
                    print("📦 Found file in bundle at: \(url.path)")
                    do {
                        modelEntity = try Entity.loadModel(contentsOf: url)
                        print("✅ Successfully loaded model from URL")
                    } catch {
                        print("❌ Method 3 failed: \(error)")
                    }
                } else {
                    print("❌ File not found in bundle: \(name).usdz")
                    print("📦 Bundle path: \(Bundle.main.bundlePath)")
                }
            }
        }
        
        if let modelEntity = modelEntity {
            modelEntity.scale = SIMD3<Float>(repeating: scale)
            modelEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.rotation, .scale, .translation], for: modelEntity)
            anchor.addChild(modelEntity)
        } else {
            print("📦 Creating fallback blue box")
            let mesh = MeshResource.generateBox(size: scale)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let fallbackEntity = ModelEntity(mesh: mesh, materials: [material])
            
            fallbackEntity.generateCollisionShapes(recursive: true)
            arView.installGestures([.rotation, .scale, .translation], for: fallbackEntity)
            
            anchor.addChild(fallbackEntity)
        }
    }
    
    func changeObjectColor(to color: UIColor) {
        for anchor in arView.scene.anchors {
            for child in anchor.children {
                if let modelEntity = child as? ModelEntity {
                    var material = SimpleMaterial()
                    material.color = .init(tint: color)
                    material.metallic = .float(0.5)
                    material.roughness = .float(0.3)
                    
                    if modelEntity.model?.materials.count ?? 0 > 0 {
                        modelEntity.model?.materials = Array(repeating: material, count: modelEntity.model!.materials.count)
                    }
                }
            }
        }
    }
    
    func changeObjectTexture(to textureName: String, image: UIImage) {
        for anchor in arView.scene.anchors {
            for child in anchor.children {
                if let modelEntity = child as? ModelEntity {
                    do {
                        let textureResource = try TextureResource.generate(from: image.cgImage!, options: .init(semantic: .color))
                        
                        var material = SimpleMaterial()
                        material.color = .init(texture: .init(textureResource))
                        material.metallic = .float(0.3)
                        material.roughness = .float(0.5)
                        
                        if modelEntity.model?.materials.count ?? 0 > 0 {
                            modelEntity.model?.materials = Array(repeating: material, count: modelEntity.model!.materials.count)
                        }
                        
                        print("✅ Applied texture: \(textureName)")
                    } catch {
                        print("❌ Failed to create texture resource: \(error)")
                    }
                }
            }
        }
    }
}
