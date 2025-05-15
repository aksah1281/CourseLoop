import SwiftUI

struct WelcomeView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    @State private var isShowingNextScreen = false
    
    var body: some View {
        ZStack {
            // Plain background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Logo in the middle with zoom animation
                Image("logo-mian")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(logoScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            logoScale = 1.0
                        }
                        
                        // Start the text fade-in after logo animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeIn(duration: 1.0)) {
                                textOpacity = 1.0
                            }
                        }
                    }
                
                // App name with fade-in animation
                Text("CourseLoop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .opacity(textOpacity)
                
                Spacer()
                
                // Tagline with fade-in animation
                Text("Connect. Help. Learn. Anonymously.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
                    .opacity(textOpacity)
            }
        }
        .onTapGesture {
            isShowingNextScreen = true
        }
        .fullScreenCover(isPresented: $isShowingNextScreen) {
            EmailLoginView()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
