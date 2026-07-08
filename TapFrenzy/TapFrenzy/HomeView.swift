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

                VStack(spacing: 28) {
                    Text("Mini Games")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 60)

                    NavigationLink {
                        TapFrenzyView()
                    } label: {
                        modeButton(title: "Tap Frenzy", subtitle: "Tap fast, beat the 10s clock")
                    }

                    NavigationLink {
                        LightItUpView()
                    } label: {
                        modeButton(title: "Light It Up", subtitle: "Whack-a-mole — grid grows, window shrinks")
                    }

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
    }

    private func modeButton(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title).font(.title2.bold())
            Text(subtitle).font(.subheadline).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .foregroundColor(.indigo)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView()
}
