import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var email = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.5),
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Activities
                OnboardingPage1()
                    .tag(0)
                
                // Page 2: Don't Play Alone
                OnboardingPage2(currentPage: $currentPage)
                    .tag(1)
                
                // Page 3: Create Account
                OnboardingPage3(email: $email, currentPage: $currentPage)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Navigation Controls
            VStack {
                Spacer()
                
                if currentPage < 2 {
                    HStack {
                        // Skip button
                        Button("Skip") {
                            currentPage = 2
                        }
                        .foregroundColor(.white)
                        .opacity(0.7)
                        
                        Spacer()
                        
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                        
                        // Next button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Character illustration
            CharacterView(size: 200)
            
            VStack(spacing: 20) {
                Text("Padel, running, and more.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Find all your favorite activities in app.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Share the workout, the excitement, and the laughter with people like you.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage2: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 40) {
            // Back button
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = 0
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
            
            // Character illustration
            CharacterView(size: 200)
            
            VStack(spacing: 20) {
                Text("Dont Play Alone!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Meet people who love the same sport as you, and live the experience together.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage3: View {
    @Binding var email: String
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack {
            // Light background for the signup page
            Color(red: 0.95, green: 0.95, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Back button
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage = 1
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer()
                
                // Character illustration (smaller version)
                CharacterView(size: 100)
                
                // Title
                Text("Anis")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.black)
                
                VStack(spacing: 20) {
                    Text("Create an account")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Enter your email to sign up for this app")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Email input field
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                
                // Continue with Apple button
                Button(action: {
                    // Handle Apple sign in
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(.white)
                        Text("Continue with Apple")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                // Terms and Privacy
                VStack(spacing: 5) {
                    Text("By clicking continue, you agree to our Terms of Service and")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView()
}