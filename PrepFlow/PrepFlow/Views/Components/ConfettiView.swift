import SwiftUI

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    let pieceCount: Int
    
    init(pieceCount: Int = 50) {
        self.pieceCount = pieceCount
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, isAnimating: isAnimating)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
                withAnimation(.easeOut(duration: 3.0)) {
                    isAnimating = true
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateConfetti(in size: CGSize) {
        confettiPieces = (0..<pieceCount).map { _ in
            ConfettiPiece(
                color: colors.randomElement() ?? .blue,
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                targetPosition: CGPoint(
                    x: CGFloat.random(in: -50...size.width + 50),
                    y: size.height + 50
                ),
                rotation: Double.random(in: 0...360),
                targetRotation: Double.random(in: 360...1080),
                scale: CGFloat.random(in: 0.5...1.5),
                shape: ConfettiShape.allCases.randomElement() ?? .rectangle,
                delay: Double.random(in: 0...0.5)
            )
        }
    }
}

// MARK: - Confetti Piece Model
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let position: CGPoint
    let targetPosition: CGPoint
    let rotation: Double
    let targetRotation: Double
    let scale: CGFloat
    let shape: ConfettiShape
    let delay: Double
}

enum ConfettiShape: CaseIterable {
    case rectangle
    case circle
    case triangle
}

// MARK: - Confetti Piece View
struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let isAnimating: Bool
    
    var body: some View {
        Group {
            switch piece.shape {
            case .rectangle:
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 12)
            case .circle:
                Circle()
                    .fill(piece.color)
                    .frame(width: 10, height: 10)
            case .triangle:
                Triangle()
                    .fill(piece.color)
                    .frame(width: 10, height: 10)
            }
        }
        .scaleEffect(piece.scale)
        .rotationEffect(.degrees(isAnimating ? piece.targetRotation : piece.rotation))
        .position(
            x: isAnimating ? piece.targetPosition.x : piece.position.x,
            y: isAnimating ? piece.targetPosition.y : piece.position.y
        )
        .opacity(isAnimating ? 0 : 1)
        .animation(
            .easeOut(duration: 3.0)
            .delay(piece.delay),
            value: isAnimating
        )
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Confetti Modifier
struct ConfettiModifier: ViewModifier {
    @Binding var isShowing: Bool
    let pieceCount: Int
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isShowing {
                    ConfettiView(pieceCount: pieceCount)
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                isShowing = false
                            }
                        }
                }
            }
    }
}

extension View {
    func confetti(isShowing: Binding<Bool>, pieceCount: Int = 50) -> some View {
        modifier(ConfettiModifier(isShowing: isShowing, pieceCount: pieceCount))
    }
}

// MARK: - Celebration Burst
struct CelebrationBurst: View {
    @State private var particles: [Particle] = []
    @State private var isAnimating = false
    
    let color: Color
    let particleCount: Int
    
    init(color: Color = .yellow, particleCount: Int = 20) {
        self.color = color
        self.particleCount = particleCount
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: isAnimating ? particle.targetX : 0,
                        y: isAnimating ? particle.targetY : 0
                    )
                    .scaleEffect(isAnimating ? 0.1 : 1)
                    .opacity(isAnimating ? 0 : 1)
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 50...150)
            return Particle(
                targetX: cos(angle) * distance,
                targetY: sin(angle) * distance,
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.6...1.0)
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let targetX: CGFloat
    let targetY: CGFloat
    let size: CGFloat
    let opacity: Double
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView()
    }
}
