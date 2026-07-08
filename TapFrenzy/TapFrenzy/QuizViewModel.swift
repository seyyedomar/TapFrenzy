//
//  QuizViewModel.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//
import Foundation

enum QuizViewState {
    case loading
    case loaded
    case failed
}

enum AnswerFeedback: Equatable {
    case correct
    case wrong
}

@MainActor
final class QuizViewModel: ObservableObject {

    @Published var viewState: QuizViewState = .loading
    @Published var questions: [TriviaQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var shuffledAnswers: [String] = []
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var answerFeedback: AnswerFeedback? = nil
    @Published var isRoundComplete: Bool = false

    private let service = TriviaService()

    var currentQuestion: TriviaQuestion? {
        guard questions.indices.contains(currentIndex) else { return nil }
        return questions[currentIndex]
    }

    var questionNumber: Int { currentIndex + 1 }
    var totalQuestions: Int { questions.count }

    func loadQuestions() async {
        viewState = .loading
        do {
            let fetched = try await service.fetchQuestions()
            questions = fetched
            currentIndex = 0
            score = 0
            streak = 0
            bestStreak = 0
            isRoundComplete = false
            shuffleAnswersForCurrentQuestion()
            viewState = .loaded
        } catch {
            viewState = .failed
        }
    }

    private func shuffleAnswersForCurrentQuestion() {
        guard let question = currentQuestion else {
            shuffledAnswers = []
            return
        }
        var answers = question.decodedIncorrectAnswers
        answers.append(question.decodedCorrectAnswer)
        shuffledAnswers = answers.shuffled()
    }

    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion, answerFeedback == nil else { return }

        let isCorrect = answer == question.decodedCorrectAnswer

        if isCorrect {
            streak += 1
            bestStreak = max(bestStreak, streak)
            let streakBonus = min(streak - 1, 5)
            score += 10 + streakBonus
            answerFeedback = .correct
        } else {
            streak = 0
            score = max(0, score - 3)
            answerFeedback = .wrong
        }

        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.answerFeedback = nil
            self.advanceToNextQuestion()
        }
    }

    private func advanceToNextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            shuffleAnswersForCurrentQuestion()
        } else {
            isRoundComplete = true
        }
    }
}
