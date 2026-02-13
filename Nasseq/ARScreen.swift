import SwiftUI
import RealityKit

struct ARScreen: View {
    @StateObject private var arManager = ARManager()
    @StateObject private var modelLibrary = ModelLibrary()
    
    // Optional: The name of the model to place immediately upon opening
    var initialModelName: String?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(arManager: arManager, modelLibrary: modelLibrary)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                // Selected Item Name
                if let selected = modelLibrary.selectedModel {
                    Text(selected.name)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .cornerRadius(20)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(modelLibrary.availableModels) { model in
                            Button {
                                modelLibrary.selectedModel = model
                                arManager.placeObject(named: model.filename)
                            } label: {
                                VStack {
                                    Image(systemName: "cube.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(modelLibrary.selectedModel?.id == model.id ? .white : .nasseqTeal)
                                    
                                    Text(model.name)
                                        .font(.caption2.bold())
                                        .foregroundColor(modelLibrary.selectedModel?.id == model.id ? .white : .primary)
                                }
                                .padding(12)
                                .background {
                                    if modelLibrary.selectedModel?.id == model.id {
                                        Color.nasseqTeal
                                    } else {
                                        Rectangle()
                                            .fill(.thinMaterial)
                                    }
                                }
                                .cornerRadius(16)
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
            .padding(.bottom, 10)
        }
        .onAppear {
            if let initialName = initialModelName {
                // Find the model object to set as selected
                if let model = modelLibrary.availableModels.first(where: { $0.filename == initialName }) {
                    modelLibrary.selectedModel = model
                }
                
                // Delay slightly to let AR session start
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    arManager.placeObject(named: initialName)
                }
            }
        }
    }
}

#Preview {
    ARScreen()
}
