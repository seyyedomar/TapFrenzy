//
//  TapFrenzyVM.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-09.
//
import SwiftUI
import Combine

enum TapFrenzyPhase {
    case ready
    case playing
    case gameOver
}

@MainActor
final class TapFrenzyVM: ObservableObject {

    @Published var phase: TapFrenzyPhase = .ready
    @Published var score: Int = 0
    @Published var timeRemaining: Double = 10.0
    @Published var multiplier: Int = 1
    @Published var isNewHighScore: Bool = false

    @AppStorage("tapFrenzyHighScore") var highScore: Int = 0

    let startDuration: Double = 10.0
    private let minButtonScale: CGFloat = 0.4
    private let comboWindow: TimeInterval = 0.5
    private let maxMultiplier: Int = 5

    private var lastTapDate: Date?
    private var timerCancellable: AnyCancellable?

    var buttonScale: CGFloat {
        let progress = timeRemaining / startDuration
        return minButtonScale + (1.0 - minButtonScale) * CGFloat(max(progress, 0))
    }

    func start() {
        score = 0
        timeRemaining = startDuration
        multiplier = 1
        lastTapDate = nil
        isNewHighScore = false
        phase = .playing

        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        timeRemaining = max(0, timeRemaining - 0.1)
        if timeRemaining <= 0 {
            end()
        }
    }

    func tap() {
        guard phase == .playing, timeRemaining > 0 else { return }

        let now = Date()
        if let last = lastTapDate, now.timeIntervalSince(last) <= comboWindow {
            multiplier = min(multiplier + 1, maxMultiplier)
        } else {
            multiplier = 1
        }
        lastTapDate = now
        score += multiplier
    }

    private func end() {
        timerCancellable?.cancel()
        phase = .gameOver
        if score > highScore {
            highScore = score
            isNewHighScore = true
        }
        GameSessionRecorder.record(mode: .tapFrenzy, score: score)
    }
}
