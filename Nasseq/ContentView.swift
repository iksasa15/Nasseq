import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                NavigationLink(destination: ARScreen()) {
                     Text("Open Camera")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .navigationTitle("Nasseq")
        }
    }
}

#Preview {
    ContentView()
}
