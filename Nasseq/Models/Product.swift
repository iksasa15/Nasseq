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
struct Product: Identifiable, Codable, Hashable {
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
