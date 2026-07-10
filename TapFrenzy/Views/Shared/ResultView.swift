//
//  ResultView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//

import SwiftUI

struct ResultView: View {
    let mode: GameMode
    let score: Int
    let isNewHighScore: Bool
    let highScore: Int
    let extraInfo: String?     
    let onPlayAgain: () -> Void

    private var shareMessage: String {
        "I just scored \(score) on \(mode.displayName) — beat that!"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("\(mode.displayName) Complete!")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            ScoreBadge(score: score)

            if isNewHighScore {
                Text("🎉 New High Score!")
                    .font(.headline)
                    .foregroundColor(.yellow)
            } else {
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            if let extraInfo {
                Text(extraInfo)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 16) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.title3.bold())
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(Capsule())
                }

                ShareLink(item: shareMessage) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.indigo.ignoresSafeArea()
        ResultView(
            mode: .quizRush,
            score: 47,
            isNewHighScore: true,
            highScore: 47,
            extraInfo: "Best Streak: 6",
            onPlayAgain: {}
        )
    }
}

