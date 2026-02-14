import Foundation
import Combine

class FavoritesManager: ObservableObject {
    @Published var favoriteIds: Set<UUID> = []
    
    private let userDefaultsKey = "nasseq_favorites"
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Load from UserDefaults
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            favoriteIds = decoded
        }
    }
    
    // MARK: - Save to UserDefaults
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ productId: UUID) {
        if favoriteIds.contains(productId) {
            favoriteIds.remove(productId)
        } else {
            favoriteIds.insert(productId)
        }
        saveFavorites()
    }
    
    // MARK: - Check if Favorited
    func isFavorite(_ productId: UUID) -> Bool {
        favoriteIds.contains(productId)
    }
    
    // MARK: - Get Favorite Products
    func favoriteProducts(from catalog: [Product]) -> [Product] {
        catalog.filter { favoriteIds.contains($0.id) }
    }
    
    // MARK: - Clear All
    func clearAll() {
        favoriteIds.removeAll()
        saveFavorites()
    }
}
