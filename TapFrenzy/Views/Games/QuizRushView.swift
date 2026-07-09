//
//  QuizRushView.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-08.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var shakeAmount: CGFloat = 0

    var body: some View {
        ZStack {
            backgroundGradient

            switch viewModel.viewState {
            case .loading:
                loadingView
            case .failed:
                failedView
            case .loaded:
                if viewModel.isRoundComplete {
                    resultsView
                } else {
                    quizView
                }
            }
        }
        .task {
            await viewModel.loadQuestions()
        }
        .onChange(of: viewModel.answerFeedback) { feedback in
            guard feedback == .wrong else { return }
            withAnimation(.default.repeatCount(3, autoreverses: true).speed(6)) {
                shakeAmount = 12
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                shakeAmount = 0
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
// LOADING STATE
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading questions…")
                .foregroundColor(.white.opacity(0.8))
        }
    }
// FAILED STATE
    private var failedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 44))
                .foregroundColor(.white)
            Text("Couldn't load questions")
                .font(.title3.bold())
                .foregroundColor(.white)
            Text("Check your connection and try again.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Button {
                Task { await viewModel.loadQuestions() }
            } label: {
                Text("Retry")
                    .font(.title2.bold())
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 32)
    }
//LOADED
    private var quizView: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Question \(viewModel.questionNumber) of \(viewModel.totalQuestions)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                if viewModel.streak > 1 {
                    Text("🔥 \(viewModel.streak) streak")
                        .font(.subheadline.bold())
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Text("Score: \(viewModel.score)")
                .font(.headline)
                .foregroundColor(.white)

            if let question = viewModel.currentQuestion {
                Text(question.decodedQuestion)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 100)
            }

            VStack(spacing: 14) {
                ForEach(viewModel.shuffledAnswers, id: \.self) { answer in
                    answerButton(answer)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .offset(x: shakeAmount)
    }

    private func answerButton(_ answer: String) -> some View {
        let feedback = viewModel.answerFeedback
        let isCorrectAnswer = answer == viewModel.currentQuestion?.decodedCorrectAnswer

        var backgroundColor: Color = .white
        if let feedback {
            if feedback == .correct && isCorrectAnswer {
                backgroundColor = .green
            } else if feedback == .wrong && isCorrectAnswer {
                backgroundColor = .green
            } else if feedback == .wrong {
                backgroundColor = .red.opacity(0.85)
            }
        }

        return Button {
            viewModel.selectAnswer(answer)
        } label: {
            Text(answer)
                .font(.body.bold())
                .foregroundColor(feedback == nil ? .indigo : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.answerFeedback != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.answerFeedback)
    }
// RESULTS STATE
    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Round Complete!")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(viewModel.score)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Best Streak: \(viewModel.bestStreak)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Button {
                Task { await viewModel.loadQuestions() }
            } label: {
                Text("Play Again")
                    .font(.title2.bold())
                    .foregroundColor(.indigo)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack { QuizRushView() }
}
