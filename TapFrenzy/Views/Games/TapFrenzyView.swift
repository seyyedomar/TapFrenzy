//
//  TapFrenzyView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-07.
//
import SwiftUI

struct TapFrenzyView: View {
    @StateObject private var vm = TapFrenzyVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundGradient

            switch vm.phase {
            case .ready:
                readyView
            case .playing:
                gameView
            case .gameOver:
                gameOverView
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
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

            Text("High Score: \(vm.highScore)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))

            Button(action: vm.start) {
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
                Text("\(vm.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if vm.multiplier > 1 {
                    Text("×\(vm.multiplier) COMBO")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.top, 20)

            Spacer()

            Button(action: vm.tap) {
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
            .scaleEffect(vm.buttonScale)
            .animation(.easeInOut(duration: 0.2), value: vm.buttonScale)

            Spacer()

            Text(String(format: "%.1fs", vm.timeRemaining))
                .font(.title.monospacedDigit())
                .foregroundColor(.white)
                .padding(.bottom, 30)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Time's Up!")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(vm.score)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if vm.isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("High Score: \(vm.highScore)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Button(action: vm.start) {
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
}

#Preview {
    NavigationStack { TapFrenzyView() }
}
