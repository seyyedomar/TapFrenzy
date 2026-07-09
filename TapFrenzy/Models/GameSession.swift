//
//  GameSession.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-09.
//
//
//  One record per completed game.


import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


@MainActor
final class GameSessionStore: ObservableObject {
    static let shared = GameSessionStore()

    @Published private(set) var sessions: [GameSession] = []

    private let storageKey = "playHubGameSessions"

    private init() {
        load()
    }

    func addSession(mode: GameMode, score: Int, latitude: Double, longitude: Double) {
        let session = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        sessions.append(session)
        save()
    }

    func resetAll() {
        sessions = []
        save()
    }

    func sessions(for mode: GameMode) -> [GameSession] {
        sessions.filter { $0.mode == mode }
    }

    func bestScore(for mode: GameMode) -> Int {
        sessions(for: mode).map(\.score).max() ?? 0
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([GameSession].self, from: data) else { return }
        sessions = decoded
    }
}


enum GameSessionRecorder {
    @MainActor
    static func record(mode: GameMode, score: Int) {
        let coordinate = LocationService.shared.currentLocation
        GameSessionStore.shared.addSession(
            mode: mode,
            score: score,
            latitude: coordinate?.latitude ?? 0,
            longitude: coordinate?.longitude ?? 0
        )
    }
}

