//
//  SymbolQuizView.swift
//  SymbolKit
//
//  Created by Yugo Sugiyama on 2024/10/30.
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
    @FocusState private var isFocused: Bool

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
        VStack(alignment: .center, spacing: 20) {
            titleContent
                .padding()
                .frame(height: 120)
            ZStack {
                Group {
                    if shouldShowAnswer {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 10,
                            lineColor: .white,
                            duration: answerDrawingDuration,
                            isPaused: false,
                            shapeAspectRatio: shapeAspectRatio
                        )
                    } else {
                        StrokeAnimationShapeView(
                            shape: shape,
                            lineWidth: 10,
                            lineColor: .white,
                            duration: questionDrawingDuration,
                            isPaused: isPaused,
                            shapeAspectRatio: shapeAspectRatio
                        )
                    }
                }
                .aspectRatio(shapeAspectRatio, contentMode: .fit)
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .foregroundStyle(.red)
                    .shadow(radius: 10)
                    .opacity(shouldShowCorrectMark ? 1 : 0)
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .foregroundStyle(.blue)
                    .shadow(radius: 10)
                    .opacity(shouldShowNotCorrectMark ? 1 : 0)
            }
            HStack(spacing: 50) {
                Button {
                    isPaused.toggle()
                } label: {
                    Image(systemName: isPaused ? "play.fill" : "stop.fill")
                        .resizable()
                        .padding(20)
                        .frame(width: 120, height: 120)
                }
                Button {
                    shouldShowAnswer.toggle()
                    shouldShowCorrectMark = false
                    shouldShowNotCorrectMark = false
                    Task {
                        try? await Task.sleep(for: answerDrawingDuration)
                        withAnimation(.easeInOut) {
                            shouldShowAnswerName = true
                        }
                    }
                } label: {
                    showAnswerContent
                        .padding()
                        .frame(height: 120)
                }
                Spacer()
                if !shouldShowAnswerName {
                    answerHintContent
                }
                HStack(spacing: 4) {
                    answerPrefixContent
                        .padding()
                        .frame(height: 120)
                    answerContent
                        .padding()
                        .frame(height: 120)
                }
                .opacity(shouldShowAnswerName ? 1 : 0)


            }
            .padding(.horizontal, 40)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .focusable()
        .focused($isFocused)
        .onKeyPress(.space) {
            isPaused.toggle()
            return .handled
        }
        .onKeyPress(.init("c")) {
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
            return .handled
        }
        .onKeyPress(.init("u")) {
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
            return .handled
        }
        .onAppear {
            isFocused = true
        }
    }
}
