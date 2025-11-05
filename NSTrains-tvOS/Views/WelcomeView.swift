import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.nsBlue
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with NS logo
                HStack {
                    Text("NS")
                        .font(.system(size: 120, weight: .bold))
                        .foregroundColor(.nsYellow)
                        .kerning(8)

                    Spacer()
                }
                .padding(.leading, 80)
                .padding(.top, 80)

                Spacer()

                // Main content
                VStack(spacing: 24) {
                    Text("NS Trains tvOS")
                        .font(.system(size: 96, weight: .bold))
                        .foregroundColor(.nsYellow)

                    Text("Proof of Concept")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                        .opacity(0.9)
                }
                .padding(.bottom, 80)

                // Info box
                VStack(spacing: 12) {
                    InfoRow(emoji: "🚂", text: "Dutch Railway Departures")
                    InfoRow(emoji: "📺", text: "Optimized for Apple TV")
                    InfoRow(emoji: "⚡", text: "Real-time Updates")
                }
                .frame(maxWidth: 800)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.nsYellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.nsYellow, lineWidth: 2)
                        )
                )
                .padding(.bottom, 60)

                // Get Started button
                Button(action: onGetStarted) {
                    Text("GET STARTED")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.nsBlue)
                        .padding(.horizontal, 80)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.nsYellow)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                // Footer
                VStack(spacing: 8) {
                    Text("Amberglass NS Trains")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .opacity(0.7)

                    Text("v0.1.0 POC")
                        .font(.system(size: 24))
                        .foregroundColor(.nsYellow)
                        .opacity(0.8)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

struct InfoRow: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack {
            Text(emoji)
                .font(.system(size: 36))
            Text(text)
                .font(.system(size: 36))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    WelcomeView(onGetStarted: {})
}
