import Foundation
import Combine

class ProductCatalog: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    init() {
        loadProducts()
    }
    
    // MARK: - Load Products from JSON
    func loadProducts() {
        isLoading = true
        error = nil
        
        print("🔍 Loading products from JSON...")
        
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json") else {
            let errorMsg = "Could not find products.json in bundle"
            error = errorMsg
            isLoading = false
            print("❌ \(errorMsg)")
            print("📦 Bundle path: \(Bundle.main.bundlePath)")
            return
        }
        
        print("✅ Found products.json at: \(url.path)")
        
        do {
            let data = try Data(contentsOf: url)
            print("✅ Read \(data.count) bytes from JSON")
            
            let decoder = JSONDecoder()
            let container = try decoder.decode(ProductContainer.self, from: data)
            self.products = container.products
            isLoading = false
            
            print("✅ Successfully loaded \(products.count) products")
        } catch {
            self.error = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
            print("❌ Error loading products: \(error)")
            
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("📦 Missing key: \(key.stringValue) in \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("📦 Type mismatch: expected \(type) in \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("📦 Value not found: \(type) in \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("📦 Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("📦 Unknown decoding error")
                }
            }
        }
    }
    
    // MARK: - Filter by Category
    func products(in category: ProductCategory) -> [Product] {
        products.filter { $0.category == category }
    }
    
    // MARK: - Search
    func search(query: String) -> [Product] {
        guard !query.isEmpty else { return products }
        
        let lowercased = query.lowercased()
        return products.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.nameArabic.contains(query) ||
            $0.category.displayName.contains(query)
        }
    }
    
    // MARK: - Get Product by ID
    func product(withId id: UUID) -> Product? {
        products.first { $0.id == id }
    }
}

// MARK: - JSON Container
private struct ProductContainer: Codable {
    let products: [Product]
}
