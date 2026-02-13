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
            
            VStack {
                Text(modelLibrary.selectedModel?.name ?? "Select a model")
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(modelLibrary.availableModels) { model in
                            Button {
                                modelLibrary.selectedModel = model
                                arManager.placeObject(named: model.filename)
                            } label: {
                                VStack {
                                    Image(systemName: "cube.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(modelLibrary.selectedModel?.id == model.id ? .green : .white)
                                    
                                    Text(model.name)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding(.bottom, 20)
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
