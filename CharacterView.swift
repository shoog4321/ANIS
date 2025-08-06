import SwiftUI

struct CharacterView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main character body (beige/tan color)
            Circle()
                .fill(Color(red: 0.85, green: 0.7, blue: 0.55))
                .frame(width: size, height: size)
            
            VStack(spacing: size * 0.05) {
                // Hat/Hair (dark color on top)
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(Color(red: 0.3, green: 0.2, blue: 0.1))
                    .frame(width: size * 0.7, height: size * 0.2)
                    .offset(y: -size * 0.3)
                
                // Eyes
                HStack(spacing: size * 0.1) {
                    // Left eye
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.15, height: size * 0.15)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.1, height: size * 0.1)
                    }
                    
                    // Right eye  
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: size * 0.15, height: size * 0.15)
                        
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.1, height: size * 0.1)
                    }
                }
                .offset(y: -size * 0.1)
                
                // Mustache
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(Color.black)
                    .frame(width: size * 0.3, height: size * 0.08)
                    .offset(y: size * 0.05)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CharacterView(size: 200)
        CharacterView(size: 100)
        CharacterView(size: 60)
    }
    .padding()
}