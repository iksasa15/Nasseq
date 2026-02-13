import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(colors: [Color.nasseqTeal.opacity(0.1), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Logo or Visual Element (Optional, using text for now)
                    Text("Nasseq AR")
                        .font(.custom("HelveticaNeue-Bold", size: 40))
                        .foregroundColor(.nasseqTeal)
                        .padding(.bottom, 20)
                    
                    Text("Experience your space in a new way.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    
                    NavigationLink(destination: ARScreen()) {
                         HStack {
                             Image(systemName: "camera.viewfinder")
                             Text("Start Experience")
                         }
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.nasseqTeal)
                        .cornerRadius(16)
                        .shadow(color: .nasseqTeal.opacity(0.4), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("") // Hide default title
        }
    }
}

#Preview {
    ContentView()
}
