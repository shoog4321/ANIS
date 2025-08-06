import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView()
            } else {
                // Main app content would go here
                VStack {
                    Text("Welcome to the App!")
                        .font(.largeTitle)
                        .padding()
                    
                    Button("Show Onboarding Again") {
                        showOnboarding = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}