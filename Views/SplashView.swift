import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var trainOffset: CGFloat = -200
    @State private var showContent = false

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.nsBlue
                .ignoresSafeArea()

            if !showContent {
                VStack(spacing: 40) {
                    Spacer()

                    // NS Logo with animation
                    ZStack {
                        // Glow effect
                        Text("NS")
                            .font(.system(size: 200, weight: .black))
                            .foregroundColor(.nsYellow)
                            .blur(radius: 20)
                            .opacity(logoOpacity * 0.5)

                        // Main logo
                        Text("NS")
                            .font(.system(size: 200, weight: .black))
                            .foregroundColor(.nsYellow)
                            .kerning(12)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    // Animated train icon
                    HStack(spacing: 0) {
                        Image(systemName: "train.side.front.car")
                            .font(.system(size: 60))
                            .foregroundColor(.nsYellow)

                        // Track lines
                        Rectangle()
                            .fill(Color.nsYellow.opacity(0.3))
                            .frame(width: 200, height: 4)
                    }
                    .offset(x: trainOffset)
                    .opacity(subtitleOpacity)

                    // Subtitle
                    Text("Real-Time Departures")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                        .opacity(subtitleOpacity)

                    Spacer()

                    // Loading indicator
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.nsYellow)
                        .opacity(subtitleOpacity)
                        .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo scale and fade in
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Subtitle fade in
        withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
            subtitleOpacity = 1.0
        }

        // Train animation - slide across
        withAnimation(.easeInOut(duration: 1.2).delay(0.6)) {
            trainOffset = 100
        }

        // Complete and transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
