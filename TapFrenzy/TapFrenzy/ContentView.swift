//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-07.
//
import SwiftUI

enum GamePhase {
    case ready
    case playing
    case gameOver
}

struct ContentView: View {

    @State private var phase: GamePhase = .gameOver
    @State private var score: Int = 0
    @State private var timeRemaining: Double = 10.0
    @State private var highScore: Int = 0
    @State private var isNewHighScore: Bool = false
    private let startDuration: Double = 10.0
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
        }.onReceive(timer) { _ in
            guard phase == .playing else { return }
            tick()}
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var readyView: some View {
        VStack(spacing: 24) {
            Text("Tap Frenzy")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Tap as fast as you can before time runs out!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Text("High Score: \(highScore)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Button(action: startGame) {
                Text("Start Game")
                    .font(.title2.bold())
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
    }

    private var gameView: some View {
        VStack {
            VStack(spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)

            Spacer()

            Button(action: handleTap) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("TAP")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(.indigo)
                    )
                    .shadow(radius: 10)
            }

            Spacer()

            Text(String(format: "%.1fs", timeRemaining))
                .font(.title.monospacedDigit())
                .foregroundColor(.white)
                .padding(.bottom, 40)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(score)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if isNewHighScore {
                            Text("🎉 New High Score!")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        } else {
                            Text("High Score: \(highScore)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }

            Button(action: startGame) {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
    }
    
    private func startGame() {
            score = 0
            timeRemaining = startDuration
            isNewHighScore = false
            phase = .playing
        }

        private func tick() {
            timeRemaining = max(0, timeRemaining - 0.1)
            if timeRemaining <= 0 {
                endGame()
            }
        }

        private func endGame() {
            phase = .gameOver
            if score > highScore {
                highScore = score
                isNewHighScore = true
            }
        }

        private func handleTap() {
            guard phase == .playing, timeRemaining > 0 else { return }
            score += 1
        }
    
}

#Preview {
    ContentView()
}
