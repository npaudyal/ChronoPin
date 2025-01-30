import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
}

struct GetStartedView: View {
    @State private var currentPage = 0
    
    let onboardingPages = [
        OnboardingPage(
            title: "Leave Digital\nTime Capsules",
            description: "Pin memories, messages, and moments to real-world locations that unlock at the perfect time",
            systemImage: "clock.fill"
        ),
        OnboardingPage(
            title: "Create Future\nMoments",
            description: "Set special messages to unlock for loved ones or your future self at meaningful times and places",
            systemImage: "heart.fill"
        ),
        OnboardingPage(
            title: "Discover Hidden\nStories",
            description: "Explore a world of memories and messages left by others, bringing every location to life",
            systemImage: "map.fill"
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "FFE5B4")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            VStack {
                                Text(onboardingPages[index].title)
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                                    .padding(.top, 100)
                                    .frame(maxHeight: .infinity, alignment: .top)
                                
                                Spacer()
                                
                                VStack(spacing: 40) {
                                    Image(systemName: onboardingPages[index].systemImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .foregroundColor(.black)
                                    
                                    Text(onboardingPages[index].description)
                                        .font(.system(size: 16, weight: .regular))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black.opacity(0.7))
                                        .padding(.horizontal, 32)
                                }
                                .padding(.bottom, 80)  // Add space above page indicators
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    .onChange(of: currentPage) { oldValue, newValue in
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred()
                    }
                    
                    Spacer()
                    
                    // Page Indicator
                    PageIndicator(currentPage: currentPage, pageCount: onboardingPages.count)
                        .padding(.bottom, 32)
                    
                    // Get Started Button
                    Button {
                                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                               let window = windowScene.windows.first {
                                                let signUpView = UIHostingController(rootView: SignUpView())
                                                signUpView.modalPresentationStyle = .fullScreen
                                                window.rootViewController?.present(signUpView, animated: true)
                                            }
                                        } label: {
                                            Text("Start Your Journey")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 56)
                                                .background(Color.black)
                                                .cornerRadius(28)
                                                .padding(.horizontal, 24)
                                        }
                                        .padding(.bottom, 48)
                                    }
                                }
                                .navigationBarHidden(true)
        }
    }
}

struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.black : Color.black.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    GetStartedView()
}
