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
        
        guard let url = Bundle.main.url(forResource: "products", withExtension: "json") else {
            error = "Could not find products.json in bundle"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let container = try decoder.decode(ProductContainer.self, from: data)
            self.products = container.products
            isLoading = false
        } catch {
            self.error = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
            print("Error loading products: \(error)")
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
