import SwiftUI

// MARK: - View Extensions for Animations
extension View {
    /// Applies a staggered animation to child views
    func staggeredAnimation(index: Int, baseDelay: Double = 0.05) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * baseDelay)) {
                    // Animation handled by parent
                }
            }
    }
    
    /// Bounce animation effect
    func bounceEffect(trigger: Bool) -> some View {
        self
            .scaleEffect(trigger ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: trigger)
    }
    
    /// Pulse animation
    func pulseAnimation(isActive: Bool) -> some View {
        self
            .scaleEffect(isActive ? 1.1 : 1.0)
            .animation(
                isActive ?
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                    .default,
                value: isActive
            )
    }
    
    /// Shimmer loading effect
    func shimmer(isActive: Bool) -> some View {
        self
            .overlay {
                if isActive {
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: isActive ? 400 : -400)
                    .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isActive)
                }
            }
            .clipped()
    }
}

// MARK: - Custom Transitions
extension AnyTransition {
    /// Slide and fade transition
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Scale and fade transition
    static var scaleAndFade: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    /// Pop transition
    static var pop: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 1.2).combined(with: .opacity)
        )
    }
    
    /// Slide from bottom with fade
    static var slideUp: AnyTransition {
        .move(edge: .bottom).combined(with: .opacity)
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int
    let font: Font
    let color: Color
    
    @State private var displayedValue: Int = 0
    
    init(value: Int, font: Font = .title.bold(), color: Color = .primary) {
        self.value = value
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text("\(displayedValue)")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText())
            .onAppear {
                animateValue()
            }
            .onChange(of: value) { _, _ in
                animateValue()
            }
    }
    
    private func animateValue() {
        let steps = min(abs(value - displayedValue), 20)
        guard steps > 0 else {
            displayedValue = value
            return
        }
        
        let duration = 0.5
        let stepDuration = duration / Double(steps)
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    displayedValue = displayedValue + (value > displayedValue ? 1 : -1) * (value - displayedValue > 0 ? 1 : -1)
                    if step == steps {
                        displayedValue = value
                    }
                }
            }
        }
    }
}

// MARK: - Loading Dots Animation
struct LoadingDots: View {
    @State private var isAnimating = false
    let color: Color
    
    init(color: Color = .primary) {
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Progress Ring Animation
struct AnimatedProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 8, color: Color = .blue) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 1), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}

// MARK: - Typing Text Animation
struct TypingText: View {
    let text: String
    let speed: Double
    
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    
    init(_ text: String, speed: Double = 0.05) {
        self.text = text
        self.speed = speed
    }
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                typeText()
            }
    }
    
    private func typeText() {
        guard currentIndex < text.count else { return }
        
        let index = text.index(text.startIndex, offsetBy: currentIndex)
        displayedText += String(text[index])
        currentIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            typeText()
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AnimatedCounter(value: 42, color: .blue)
        LoadingDots(color: .purple)
        AnimatedProgressRing(progress: 0.7, color: .green)
            .frame(width: 100, height: 100)
        TypingText("Hello, World!")
    }
    .padding()
}
