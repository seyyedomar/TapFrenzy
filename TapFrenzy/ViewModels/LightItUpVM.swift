//
//  LightItUpVM.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-09.
//
import SwiftUI
import Combine

@MainActor
final class LightItUpVM: ObservableObject {

    enum RoundPhase {
        case ready
        case playing
        case gameOver
    }

    @Published var phase: RoundPhase = .ready
    @Published var score: Int = 0
    @Published var elapsed: Double = 0
    @Published var level: GameLevel = .one
    @Published var cards: [Card] = []
    @Published var isNewHighScore: Bool = false
    @Published var showLevelFlash: Bool = false

    @AppStorage("lightItUpHighScore") var highScore: Int = 0

    let roundDuration: Double = 60
    private var litAccumulator: Double = 0
    private var timerCancellable: AnyCancellable?

    func start() {
        score = 0
        elapsed = 0
        litAccumulator = 0
        level = .one
        isNewHighScore = false
        cards = makeCards(count: level.cardCount)
        phase = .playing

        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func makeCards(count: Int) -> [Card] {
        (0..<count).map { _ in Card() }
    }

    private func tick() {
        elapsed += 0.1

        if elapsed >= roundDuration {
            end()
            return
        }

        let newLevel = GameLevel.level(forElapsed: elapsed)
        if newLevel != level {
            level = newLevel
            cards = makeCards(count: level.cardCount)
            litAccumulator = 0
            flashLevelUp()
        }

        litAccumulator += 0.1
        if litAccumulator >= level.litWindow {
            litAccumulator = 0
            cycleLitCards()
        }
    }

    private func cycleLitCards() {
        for index in cards.indices where cards[index].isLit {
            cards[index].isLit = false
            score = max(0, score - 1)
        }
        let indicesToLight = Array(cards.indices).shuffled().prefix(level.simultaneousLitCount)
        for index in indicesToLight {
            cards[index].isLit = true
        }
    }

    func tap(_ card: Card) {
        guard phase == .playing,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            score += 1
            cards[index].isLit = false
        } else {
            score = max(0, score - 1)
        }
    }

    private func flashLevelUp() {
        showLevelFlash = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            showLevelFlash = false
        }
    }

    private func end() {
        timerCancellable?.cancel()
        phase = .gameOver
        if score > highScore {
            highScore = score
            isNewHighScore = true
        }
        GameSessionRecorder.record(mode: .lightItUp, score: score)
    }
}
