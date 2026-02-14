import SwiftUI

struct ARCameraTab: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isActive = false
    
    var body: some View {
        Color.clear
            .fullScreenCover(isPresented: .constant(true)) {
                ARScreen(selectedProduct: nil)
            }
    }
}
