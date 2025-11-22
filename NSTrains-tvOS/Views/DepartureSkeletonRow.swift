import SwiftUI

struct DepartureSkeletonRow: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 20) {
            // Time
            SkeletonBox(width: 80, height: 30)
                .frame(width: 120, alignment: .leading)

            // Train
            SkeletonBox(width: 70, height: 26)
                .frame(width: 100, alignment: .leading)

            // Type
            SkeletonBox(width: 120, height: 26)
                .frame(width: 160, alignment: .leading)

            // Destination
            VStack(alignment: .leading, spacing: 4) {
                SkeletonBox(width: 250, height: 28)
                SkeletonBox(width: 180, height: 22)
            }
            .frame(minWidth: 300, alignment: .leading)

            // Platform
            SkeletonBox(width: 60, height: 30)
                .frame(width: 140, alignment: .center)

            // Delay
            SkeletonBox(width: 40, height: 26)
                .frame(width: 100, alignment: .center)

            // Status
            SkeletonBox(width: 100, height: 24)
                .frame(width: 140, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct SkeletonBox: View {
    let width: CGFloat
    let height: CGFloat
    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.1)
                    ]),
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating.toggle()
                }
            }
    }
}

#Preview {
    ZStack {
        Color.nsBlue.ignoresSafeArea()

        VStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { _ in
                DepartureSkeletonRow()
            }
        }
        .padding()
    }
}
