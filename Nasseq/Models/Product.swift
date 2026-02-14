import Foundation
import SwiftUI

// MARK: - Product Category
enum ProductCategory: String, Codable, CaseIterable {
    case plates = "plates"
    case cups = "cups"
    case bowls = "bowls"
    case centerpieces = "centerpieces"
    case cutlery = "cutlery"
    
    var displayName: String {
        switch self {
        case .plates: return "أطباق"
        case .cups: return "أكواب"
        case .bowls: return "أوعية"
        case .centerpieces: return "قطع مركزية"
        case .cutlery: return "أدوات المائدة"
        }
    }
    
    var icon: String {
        switch self {
        case .plates: return "circle.circle"
        case .cups: return "cup.and.saucer.fill"
        case .bowls: return "bowl.fill"
        case .centerpieces: return "sparkles"
        case .cutlery: return "fork.knife"
        }
    }
}

// MARK: - Product Model
struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let nameArabic: String
    let category: ProductCategory
    let modelFilename: String
    let thumbnailName: String?
    let realWorldScale: Float // in meters (e.g., 0.27 for a 27cm plate)
    let description: String?
    let descriptionArabic: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        nameArabic: String,
        category: ProductCategory,
        modelFilename: String,
        thumbnailName: String? = nil,
        realWorldScale: Float,
        description: String? = nil,
        descriptionArabic: String? = nil
    ) {
        self.id = id
        self.name = name
        self.nameArabic = nameArabic
        self.category = category
        self.modelFilename = modelFilename
        self.thumbnailName = thumbnailName
        self.realWorldScale = realWorldScale
        self.description = description
        self.descriptionArabic = descriptionArabic
    }
}

// MARK: - Codable Implementation
extension Product: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, nameArabic, category, modelFilename, thumbnailName, realWorldScale, description, descriptionArabic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as either String or UUID
        if let idString = try? container.decode(String.self, forKey: .id) {
            // Try to create UUID from string, or generate new one if invalid
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.nameArabic = try container.decode(String.self, forKey: .nameArabic)
        self.category = try container.decode(ProductCategory.self, forKey: .category)
        self.modelFilename = try container.decode(String.self, forKey: .modelFilename)
        self.thumbnailName = try? container.decode(String.self, forKey: .thumbnailName)
        self.realWorldScale = try container.decode(Float.self, forKey: .realWorldScale)
        self.description = try? container.decode(String.self, forKey: .description)
        self.descriptionArabic = try? container.decode(String.self, forKey: .descriptionArabic)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(nameArabic, forKey: .nameArabic)
        try container.encode(category, forKey: .category)
        try container.encode(modelFilename, forKey: .modelFilename)
        try container.encodeIfPresent(thumbnailName, forKey: .thumbnailName)
        try container.encode(realWorldScale, forKey: .realWorldScale)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(descriptionArabic, forKey: .descriptionArabic)
    }
}

// MARK: - Sample Products for Preview
extension Product {
    static let samples: [Product] = [
        Product(
            name: "White Ceramic Plate",
            nameArabic: "طبق سيراميك أبيض",
            category: .plates,
            modelFilename: "plate_ceramic_white",
            realWorldScale: 0.27,
            description: "Classic white dinner plate",
            descriptionArabic: "طبق عشاء أبيض كلاسيكي"
        ),
        Product(
            name: "Glass Cup",
            nameArabic: "كوب زجاجي",
            category: .cups,
            modelFilename: "cup_glass",
            realWorldScale: 0.12,
            description: "Clear glass drinking cup",
            descriptionArabic: "كوب شرب زجاجي شفاف"
        ),
        Product(
            name: "Ceramic Bowl",
            nameArabic: "وعاء سيراميك",
            category: .bowls,
            modelFilename: "bowl_ceramic",
            realWorldScale: 0.20,
            description: "Medium ceramic serving bowl",
            descriptionArabic: "وعاء تقديم سيراميك متوسط"
        ),
        Product(
            name: "Flower Vase",
            nameArabic: "مزهرية",
            category: .centerpieces,
            modelFilename: "vase_flower",
            realWorldScale: 0.25,
            description: "Decorative flower vase",
            descriptionArabic: "مزهرية زهور زخرفية"
        ),
        Product(
            name: "Fork & Knife Set",
            nameArabic: "طقم شوكة وسكين",
            category: .cutlery,
            modelFilename: "cutlery_set",
            realWorldScale: 0.20,
            description: "Stainless steel cutlery",
            descriptionArabic: "أدوات مائدة من الفولاذ"
        )
    ]
}
