//
//  LightItUpView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//
//
//

import SwiftUI

struct LightItUpView: View {

    private enum RoundPhase {
        case ready
        case playing
        case gameOver
    }


    @State private var phase: RoundPhase = .ready
    @State private var score: Int = 0
    @State private var elapsed: Double = 0
    @State private var level: GameLevel = .one
    @State private var cards: [Card] = []
    @State private var litAccumulator: Double = 0
    @State private var showLevelFlash: Bool = false
    @State private var isNewHighScore: Bool = false

    @AppStorage("lightItUpHighScore") private var highScore: Int = 0

    private let roundDuration: Double = 60
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()


    var body: some View {
        ZStack {
            backgroundGradient

            switch phase {
            case .ready:
                readyView
            case .playing:
                gameView
            case .gameOver:
                gameOverView
            }

            if showLevelFlash {
                levelFlashOverlay
            }
        }
        .onReceive(timer) { _ in
            guard phase == .playing else { return }
            tick()
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.black, level.glowColor.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: level.rawValue)
    }

    // MARK: - Ready Screen

    private var readyView: some View {
        VStack(spacing: 20) {
            Text("Light It Up")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Tap the lit card before it goes dark.\nThe grid grows. The window shrinks.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("High Score: \(highScore)")
                .foregroundColor(.white.opacity(0.7))

            Button(action: startRound) {
                Text("Start Round")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Game Screen

    private var gameView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(score)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL \(level.rawValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "%.0fs", max(0, roundDuration - elapsed)))
                        .font(.title3.monospacedDigit())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Spacer()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: level.columns),
                spacing: 16
            ) {
                ForEach(cards) { card in
                    cardView(card)
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.3), value: level.rawValue)

            Spacer()
        }
    }

    private func cardView(_ card: Card) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(card.isLit ? level.glowColor : Color.white.opacity(0.15))
            .frame(height: 140)
            .scaleEffect(card.isLit ? 1.08 : 1.0)
            .shadow(color: card.isLit ? level.glowColor.opacity(0.8) : .clear, radius: card.isLit ? 12 : 0)
            .animation(.easeInOut(duration: 0.15), value: card.isLit)
            .onTapGesture { handleTap(card) }
    }

    // MARK: - Game Over Screen

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Round Over")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(score)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("High Score: \(highScore)")
                    .foregroundColor(.white.opacity(0.7))
            }

            Button(action: startRound) {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
    }


    private var levelFlashOverlay: some View {
        Text("LEVEL \(level.rawValue)")
            .font(.system(size: 44, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(28)
            .background(level.glowColor.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .transition(.scale.combined(with: .opacity))
    }


    private func startRound() {
        score = 0
        elapsed = 0
        litAccumulator = 0
        level = .one
        isNewHighScore = false
        cards = makeCards(count: level.cardCount)
        phase = .playing
    }

    private func makeCards(count: Int) -> [Card] {
        (0..<count).map { _ in Card() }
    }

    private func tick() {
        elapsed += 0.1

        if elapsed >= roundDuration {
            endRound()
            return
        }

        let newLevel = GameLevel.level(forElapsed: elapsed)
        if newLevel != level {
            level = newLevel
            cards = makeCards(count: level.cardCount)
            litAccumulator = 0
            flashLevelUp()
        }

        litAccumulator += 0.1
        if litAccumulator >= level.litWindow {
            litAccumulator = 0
            cycleLitCards()
        }
    }

  
    private func cycleLitCards() {
        for index in cards.indices where cards[index].isLit {
            cards[index].isLit = false
            score = max(0, score - 1)
        }

        let indicesToLight = Array(cards.indices).shuffled().prefix(level.simultaneousLitCount)
        for index in indicesToLight {
            cards[index].isLit = true
        }
    }

    private func handleTap(_ card: Card) {
        guard phase == .playing,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            score = max(0, score - 1)
        }
    }

    private func flashLevelUp() {
        withAnimation { showLevelFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { showLevelFlash = false }
        }
    }

    private func endRound() {
        phase = .gameOver
        if score > highScore {
            highScore = score
            isNewHighScore = true
        }
    }
}

#Preview {
    NavigationStack { LightItUpView() }
}
