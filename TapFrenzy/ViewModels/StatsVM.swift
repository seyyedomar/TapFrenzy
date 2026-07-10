//
//  StatsVM.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//
//  Reads from GameSessionStore and shapes the data the Stats tab needs:
//  totals, personal bests per mode, and recent games.
//

import Foundation

@MainActor
final class StatsVM: ObservableObject {

    @Published private(set) var sessions: [GameSession] = []

    private let store = GameSessionStore.shared

    init() {
        sessions = store.sessions
    }


    func refresh() {
        sessions = store.sessions
    }

    var totalGamesPlayed: Int { sessions.count }

    var totalScore: Int { sessions.map(\.score).reduce(0, +) }

    func bestScore(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.map(\.score).max() ?? 0
    }

    func gamesPlayed(for mode: GameMode) -> Int {
        sessions.filter { $0.mode == mode }.count
    }

    var recentSessions: [GameSession] {
        sessions.sorted { $0.timestamp > $1.timestamp }.prefix(10).map { $0 }
    }
}

