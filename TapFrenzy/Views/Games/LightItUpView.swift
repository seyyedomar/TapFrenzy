//
//  LightItUpView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//
import SwiftUI

struct LightItUpView: View {
    @StateObject private var vm = LightItUpVM()
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

            if vm.showLevelFlash {
                levelFlashOverlay
            }
        }
        .navigationTitle("Light It Up")
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
            colors: [Color.black, vm.level.glowColor.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: vm.level.rawValue)
    }

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

            Text("High Score: \(vm.highScore)")
                .foregroundColor(.white.opacity(0.7))

            Button(action: vm.start) {
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

    private var gameView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SCORE")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(vm.score)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("LEVEL \(vm.level.rawValue)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(String(format: "%.0fs", max(0, vm.roundDuration - vm.elapsed)))
                        .font(.title3.monospacedDigit())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Spacer()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: vm.level.columns),
                spacing: 16
            ) {
                ForEach(vm.cards) { card in
                    cardView(card)
                }
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.3), value: vm.level.rawValue)

            Spacer()
        }
    }

    private func cardView(_ card: Card) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(card.isLit ? vm.level.glowColor : Color.white.opacity(0.15))
            .frame(height: 140)
            .scaleEffect(card.isLit ? 1.08 : 1.0)
            .shadow(color: card.isLit ? vm.level.glowColor.opacity(0.8) : .clear, radius: card.isLit ? 12 : 0)
            .animation(.easeInOut(duration: 0.15), value: card.isLit)
            .onTapGesture { vm.tap(card) }
    }

    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text("Round Over")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(vm.score)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if vm.isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("High Score: \(vm.highScore)")
                    .foregroundColor(.white.opacity(0.7))
            }

            Button(action: vm.start) {
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
        Text("LEVEL \(vm.level.rawValue)")
            .font(.system(size: 44, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .padding(28)
            .background(vm.level.glowColor.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    NavigationStack { LightItUpView() }
}
