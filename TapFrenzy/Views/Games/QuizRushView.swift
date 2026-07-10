import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushVM()
    @State private var shakeAmount: CGFloat = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundGradient

            switch vm.viewState {
            case .loading:
                loadingView
            case .failed:
                failedView
            case .loaded:
                if vm.isRoundComplete {
                    ResultView(
                        mode: .quizRush,
                        score: vm.score,
                        isNewHighScore: false,
                        highScore: vm.score,
                        extraInfo: "Best Streak: \(vm.bestStreak)",
                        onPlayAgain: { Task { await vm.loadQuestions() } }
                    )
                } else {
                    quizView
                }
            }
        }
        .task {
            await vm.loadQuestions()
        }
        .onChange(of: vm.answerFeedback) { _, feedback in
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.indigo.opacity(0.85), Color.purple.opacity(0.75)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

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
                Task { await vm.loadQuestions() }
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

    private var quizView: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Question \(vm.questionNumber) of \(vm.totalQuestions)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                if vm.streak > 1 {
                    Text("🔥 \(vm.streak) streak")
                        .font(.subheadline.bold())
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Text("Score: \(vm.score)")
                .font(.headline)
                .foregroundColor(.white)

            if let question = vm.currentQuestion {
                Text(question.decodedQuestion)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 100)
            }

            VStack(spacing: 14) {
                ForEach(vm.shuffledAnswers, id: \.self) { answer in
                    answerButton(answer)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .offset(x: shakeAmount)
    }

    private func answerButton(_ answer: String) -> some View {
        let feedback = vm.answerFeedback
        let isCorrectAnswer = answer == vm.currentQuestion?.decodedCorrectAnswer

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
            vm.selectAnswer(answer)
        } label: {
            Text(answer)
                .font(.body.bold())
                .foregroundColor(feedback == nil ? .indigo : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(vm.answerFeedback != nil)
        .animation(.easeInOut(duration: 0.2), value: vm.answerFeedback)
    }

    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Round Complete!")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("\(vm.score)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Best Streak: \(vm.bestStreak)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Button {
                Task { await vm.loadQuestions() }
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
