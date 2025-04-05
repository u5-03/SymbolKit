//
//  SymbolQuizView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

public struct SymbolQuizView<TextContent: View>: View {
    let titleContent: TextContent
    let answerPrefixContent: TextContent
    let answerContent: TextContent
    let showAnswerContent: TextContent
    let answerHintContent: TextContent
    let answerAlternativeContent: AnyView?
    let shape: any Shape
    let shapeAspectRatio: CGFloat
    let lineWidth: CGFloat
    let questionDrawingDuration: Duration
    let answerDrawingDuration: Duration

    @State private var isPaused = true
    @State private var shouldShowCorrectMark = false
    @State private var shouldShowNotCorrectMark = false
    @State private var shouldShowAnswer = false
    @State private var shouldShowAnswerName = false
    @State private var showAnswerTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    @State private var strokeAnimationViewModel: StrokeAnimationViewModel

    public init(
        @ViewBuilder titleContent: () -> TextContent,
        @ViewBuilder answerPrefixContent: () -> TextContent,
        @ViewBuilder answerContent: () -> TextContent,
        @ViewBuilder showAnswerContent: () -> TextContent,
        @ViewBuilder answerHintContent: (() -> TextContent),
        answerAlternativeContent: AnyView? = nil,
        shape: any Shape,
        shapeAspectRatio: CGFloat = 1,
        lineWidth: CGFloat = 5,
        questionDrawingDuration: Duration = .seconds(60),
        answerDrawingDuration: Duration = .seconds(5),
        pathAnimationType: PathAnimationType = .progressiveDraw
    ) {
        self.titleContent = titleContent()
        self.answerPrefixContent = answerPrefixContent()
        self.answerContent = answerContent()
        self.showAnswerContent = showAnswerContent()
        self.answerHintContent = answerHintContent()
        self.answerAlternativeContent = answerAlternativeContent
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
        self.lineWidth = lineWidth
        self.questionDrawingDuration = questionDrawingDuration
        self.answerDrawingDuration = answerDrawingDuration
        strokeAnimationViewModel = .init(animationType: pathAnimationType)
    }

    public var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center, spacing: 0) {
                titleContent
                    .minimumScaleFactor(0.1)
                    .padding(8)
                    .frame(height: proxy.size.height * 0.15)
                ZStack {
                    Group {
                        if shouldShowAnswerName, let answerAlternativeContent {
                            answerAlternativeContent
                        } else if shouldShowAnswer {
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
                                lineWidth: lineWidth,
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
                        .foregroundStyle(.red)
                        .shadow(radius: 10)
                        .opacity(shouldShowNotCorrectMark ? 1 : 0)
                }
                .frame(height: proxy.size.height * 0.7)
                bottomBarView
                    .padding(8)
                    .frame(height: proxy.size.height * 0.15)
            }
            .focusable()
            .focused($isFocused)
            .focusEffectDisabled()
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


private extension SymbolQuizView {
    var bottomBarView: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
                restartButton(height: proxy.size.height)
                Spacer()
                    .frame(width: proxy.size.width * 0.01)
                controlButton(height: proxy.size.height)
                Spacer()
                    .frame(width: proxy.size.width * 0.01)
                answerButtonSectionView
                Spacer()
                    .frame(width: proxy.size.width * 0.01)
                answerView
                    .frame(maxWidth: .infinity)
            }
        }
    }

    func restartButton(height: CGFloat) -> some View {
        Button {
            strokeAnimationViewModel.resetProgress()
            isPaused = true
            shouldShowAnswer = false
            shouldShowAnswerName = false
            showAnswerTask?.cancel()
        } label: {
            Image(systemName: "arrow.trianglehead.counterclockwise")
                .resizable()
                .padding(height * 0.2)
                .frame(width: height, height: height)
        }
    }

    func controlButton(height: CGFloat) -> some View {
        Button {
            isPaused.toggle()
        } label: {
            Image(systemName: isPaused ? "play.fill" : "stop.fill")
                .resizable()
                .padding(height * 0.2)
                .frame(width: height, height: height)
        }
    }

    var answerButtonSectionView: some View {
        VStack(spacing: 8) {
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
                    .minimumScaleFactor(0.2)
                    .padding(4)
            }
#if os(iOS)
            HStack(spacing: 32) {
                Image(systemName: "checkmark")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.green)
                    .shadow(radius: 10)
                    .onTapGesture {
                        showCorrectAnswer()
                    }
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.red)
                    .shadow(radius: 10)
                    .onTapGesture {
                        showInCorrectAnswer()
                    }
            }
#endif
        }
    }

    @ViewBuilder
    var answerView: some View {
        if !shouldShowAnswerName {
            answerHintContent
                .minimumScaleFactor(0.2)
        } else {
            HStack(spacing: 4) {
                answerPrefixContent
                    .minimumScaleFactor(0.2)
                    .padding(4)
                answerContent
                    .minimumScaleFactor(0.2)
                    .padding(4)
                Spacer()
                    .frame(width: 4)
            }
            .opacity(shouldShowAnswerName ? 1 : 0)
        }
    }
}

#Preview("Mac", traits: .fixedLayout(width: 800, height: 400)) {
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
        }, answerAlternativeContent: AnyView(
            SugiyShape()
                .stroke(.yellow)
                .aspectRatio(SugiyShape.aspectRatio, contentMode: .fit)
        ),
        shape: SugiyShape(),
        shapeAspectRatio: SugiyShape.aspectRatio
    )
    .background(Color.gray)
}

#Preview("iPad") {
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
        }, answerAlternativeContent: AnyView(
            SugiyShape()
                .stroke(.yellow)
                .aspectRatio(SugiyShape.aspectRatio, contentMode: .fit)
        ),
        shape: SugiyShape(),
        shapeAspectRatio: SugiyShape.aspectRatio
    )
    .background(Color.gray)
}

