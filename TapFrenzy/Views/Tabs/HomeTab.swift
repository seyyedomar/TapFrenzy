//
//  HomeView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Mini Games")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    NavigationLink {
                        TapFrenzyView()
                    } label: {
                        modeButton(title: "Tap Frenzy", icon: "hand.tap", color: .indigo)
                    }

                    NavigationLink {
                        LightItUpView()
                    } label: {
                        modeButton(title: "Light It Up", icon: "bolt.fill", color: .orange)
                    }
                    
                    NavigationLink {
                        QuizRushView()
                    } label: {
                        modeButton(title: "Quiz Rush", icon: "questionmark.circle", color: .green)
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
    }

    private func modeButton(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.title2.bold())
                    .foregroundColor(color)
            }

            Text(title)
                .font(.title3.bold())
                .foregroundColor(.indigo)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView()
}
