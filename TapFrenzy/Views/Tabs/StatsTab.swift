//
//  StatsTab.swift
//
//  Created by Seyyed Omar on 2026-07-10.
//  Aggregates GameSession data across all the 3 modes: totals, personal bests, recent games, and a bar chart


import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var vm = StatsVM()

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    LabeledContent("Total Games Played", value: "\(vm.totalGamesPlayed)")
                    LabeledContent("Total Score", value: "\(vm.totalScore)")
                }

                Section("Personal Bests") {
                    ForEach(GameMode.allCases) { mode in
                        LabeledContent {
                            Text("\(vm.bestScore(for: mode))")
                        } label: {
                            Label(mode.displayName, systemImage: mode.symbolName)
                        }
                    }
                }

                if !vm.sessions.isEmpty {
                    Section("Score by Session") {
                        Chart(vm.recentSessions) { session in
                            BarMark(
                                x: .value("Time", session.timestamp),
                                y: .value("Score", session.score)
                            )
                            .foregroundStyle(by: .value("Mode", session.mode.displayName))
                        }
                        .frame(height: 200)
                        .padding(.vertical, 8)
                    }
                }

                Section("Recent Games") {
                    if vm.recentSessions.isEmpty {
                        Text("No games played yet — go play one!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(vm.recentSessions) { session in
                            HStack {
                                Label(session.mode.displayName, systemImage: session.mode.symbolName)
                                Spacer()
                                Text("\(session.score)")
                                    .bold()
                                Text(session.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .onAppear { vm.refresh() }
        }
    }
}

#Preview {
    StatsTab()
}
