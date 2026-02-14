import Foundation
import simd

// MARK: - Placed Product
struct PlacedProduct: Codable, Identifiable {
    let id: UUID
    let productId: UUID
    let position: CodableFloat3
    let rotation: CodableQuaternion
    let scale: CodableFloat3
    
    init(
        id: UUID = UUID(),
        productId: UUID,
        position: SIMD3<Float>,
        rotation: simd_quatf,
        scale: SIMD3<Float>
    ) {
        self.id = id
        self.productId = productId
        self.position = CodableFloat3(position)
        self.rotation = CodableQuaternion(rotation)
        self.scale = CodableFloat3(scale)
    }
}

// MARK: - Formation Snapshot
struct FormationSnapshot: Identifiable, Codable {
    let id: UUID
    var name: String
    let date: Date
    let imagePath: String // Relative path in Documents directory
    let products: [PlacedProduct]
    
    init(
        id: UUID = UUID(),
        name: String,
        date: Date = Date(),
        imagePath: String,
        products: [PlacedProduct]
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.imagePath = imagePath
        self.products = products
    }
}

// MARK: - Codable Helpers for SIMD Types
struct CodableFloat3: Codable {
    let x: Float
    let y: Float
    let z: Float
    
    init(_ vector: SIMD3<Float>) {
        self.x = vector.x
        self.y = vector.y
        self.z = vector.z
    }
    
    var simd: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

struct CodableQuaternion: Codable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float
    
    init(_ quat: simd_quatf) {
        self.x = quat.vector.x
        self.y = quat.vector.y
        self.z = quat.vector.z
        self.w = quat.vector.w
    }
    
    var simd: simd_quatf {
        simd_quatf(vector: SIMD4<Float>(x, y, z, w))
    }
}
