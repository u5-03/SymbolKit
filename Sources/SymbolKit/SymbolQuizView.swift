//
//  SymbolQuizView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

public struct SymbolQuizView<Content: View>: View {
    let titleContent: Content
    let answerPrefixContent: Content
    let answerContent: Content
    let showAnswerContent: Content
    let answerHintContent: Content
    let shape: any Shape
    let shapeAspectRatio: CGFloat
    let questionDrawingDuration: Duration
    let answerDrawingDuration: Duration

    @State private var isPaused = true
    @State private var shouldShowCorrectMark = false
    @State private var shouldShowNotCorrectMark = false
    @State private var shouldShowAnswer = false
    @State private var shouldShowAnswerName = false
    @State private var showAnswerTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    @State private var strokeAnimationViewModel = StrokeAnimationViewModel(animationType: .fixedRatioMove(strokeLengthRatio: 0.05))

    public init(
        @ViewBuilder titleContent: () -> Content,
        @ViewBuilder answerPrefixContent: () -> Content,
        @ViewBuilder answerContent: () -> Content,
        @ViewBuilder showAnswerContent: () -> Content,
        @ViewBuilder answerHintContent: (() -> Content),
        shape: any Shape,
        shapeAspectRatio: CGFloat = 1,
        questionDrawingDuration: Duration = .seconds(60),
        answerDrawingDuration: Duration = .seconds(5)
    ) {
        self.titleContent = titleContent()
        self.answerPrefixContent = answerPrefixContent()
        self.answerContent = answerContent()
        self.showAnswerContent = showAnswerContent()
        self.answerHintContent = answerHintContent()
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
        self.questionDrawingDuration = questionDrawingDuration
        self.answerDrawingDuration = answerDrawingDuration
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            titleContent
                .padding()
                .frame(height: 100)
            ZStack {
                Group {
                    if shouldShowAnswer {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 5,
                            lineColor: .white,
                            duration: answerDrawingDuration,
                            isPaused: false,
                            shapeAspectRatio: shapeAspectRatio
                        )
                    } else {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 5,
                            lineColor: .white,
                            duration: questionDrawingDuration,
                            isPaused: isPaused,
                            shapeAspectRatio: shapeAspectRatio,
                            viewModel: strokeAnimationViewModel
                        )
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .aspectRatio(shapeAspectRatio, contentMode: .fit)
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 320, height: 320)
                    .foregroundStyle(.green)
                    .shadow(radius: 10)
                    .opacity(shouldShowCorrectMark ? 1 : 0)
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 320, height: 320)
                    .shadow(radius: 10)
                    .opacity(shouldShowNotCorrectMark ? 1 : 0)
            }
            HStack(spacing: 24) {
                Button {
                    strokeAnimationViewModel.resetProgress()
                    isPaused = true
                    shouldShowAnswer = false
                    showAnswerTask?.cancel()
                } label: {
                    Image(systemName: "arrow.trianglehead.counterclockwise")
                        .resizable()
                        .padding(20)
                        .frame(width: 120, height: 120)
                }
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "stop.fill")
                        .resizable()
                        .padding(20)
                        .frame(width: 120, height: 120)
                }
                VStack(spacing: 0) {
                    Button {
                        shouldShowAnswer.toggle()
                        shouldShowCorrectMark = false
                        shouldShowNotCorrectMark = false
                        showAnswerTask = Task {
                            try? await Task.sleep(for: answerDrawingDuration)
                            withAnimation(.easeInOut) {
                                shouldShowAnswerName = true
                            }
                        }

                    } label: {
                        showAnswerContent
                            .minimumScaleFactor(0.1)
                            .padding()
                    }
#if os(iOS)
                    HStack(spacing: 32) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundStyle(.green)
                            .shadow(radius: 10)
                            .onTapGesture {
                                showCorrectAnswer()
                            }
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundStyle(.red)
                            .shadow(radius: 10)
                            .onTapGesture {
                                showInCorrectAnswer()
                            }
                    }
#endif
                }
                Group {
                    if !shouldShowAnswerName {
                        answerHintContent
                            .minimumScaleFactor(0.1)
                    } else {
                        HStack(spacing: 4) {
                            answerPrefixContent
                                .minimumScaleFactor(0.1)
                                .padding()
                            answerContent
                                .minimumScaleFactor(0.1)
                                .padding()
                        }
                        .opacity(shouldShowAnswerName ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
            .scaledToFit()
        }
        .padding(28)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity)
        .focusable()
        .focused($isFocused)
#if os(macOS)
        .onKeyPress(.space) {
            isPaused.toggle()
            return .handled
        }
        .onKeyPress(.init("c")) {
            showCorrectAnswer()
            return .handled
        }
        .onKeyPress(.init("u")) {
            showInCorrectAnswer()
            return .handled
        }
#endif
        .onAppear {
            isFocused = true
        }
    }
}

private extension SymbolQuizView {
    func showCorrectAnswer() {
        shouldShowNotCorrectMark = false
        withAnimation(.easeInOut) {
            shouldShowCorrectMark = true
        } completion: {
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeInOut) {
                    shouldShowCorrectMark = false
                }
            }
        }
    }

    func showInCorrectAnswer() {
        shouldShowCorrectMark = false
        withAnimation(.easeInOut) {
            shouldShowNotCorrectMark = true
        } completion: {
            Task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation(.easeInOut) {
                    shouldShowNotCorrectMark = false
                }
            }
        }
    }
}

#Preview {
    SymbolQuizView(
        titleContent: {
            Text("Title")
                .lineLimit(1)
                .font(.system(size: 100, weight: .bold))
                .foregroundStyle(.blue)
        }, answerPrefixContent: {
            Text("Answer: ")
                .lineLimit(1)
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.gray)
        }, answerContent: {
            Text("Sugiy")
                .lineLimit(1)
                .font(.system(size: 100, weight: .bold))
                .foregroundStyle(.white)
        }, showAnswerContent: {
            Text("Show Answer")
                .lineLimit(1)
                .font(.system(size: 100, weight: .bold))
                .foregroundStyle(.white)
        }, answerHintContent: {
            Text("someone's icon" ?? "")
                .lineLimit(2)
                .font(.system(size: 80, weight: .bold))
                .foregroundStyle(.white)
        },
        shape: SugiyShape(),
        shapeAspectRatio: SugiyShape.aspectRatio
    )
    .background(Color.gray)
}
