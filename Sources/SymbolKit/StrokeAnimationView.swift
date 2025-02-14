//
//  StrokeAnimationView.swift
//
//
//  Created by Yugo Sugiyama on 2024/11/10.
//

import SwiftUI

public struct StrokeAnimatableShape {
    var animationProgress: CGFloat = 0
    let shape: any Shape
}

extension StrokeAnimatableShape: Shape {
    public var animatableData: CGFloat {
        get { animationProgress }
        set {
            if animationProgress >= 1.0 { return }
            animationProgress = newValue
        }
    }

    public func path(in rect: CGRect) -> Path {
        return shape.path(in: rect)
            .trimmedPath(from: 0, to: animationProgress)
    }
}

public struct StrokeAnimationShapeView: View {
    let lineWidth: CGFloat
    let lineColor: Color
    let duration: Duration
    let shape: any Shape
    let isPaused: Bool
    let shapeAspectRatio: CGFloat
    @State private var animationProgress: CGFloat = 0
    @State private var lastFrameDate: Date?

    public init(
        shape: any Shape,
        lineWidth: CGFloat = 1,
        lineColor: Color = .black,
        duration: Duration = .seconds(10),
        isPaused: Bool = false,
        shapeAspectRatio: CGFloat = 1
    ) {
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.duration = duration
        self.isPaused = isPaused
        self.shape = shape
        self.shapeAspectRatio = shapeAspectRatio
    }

    public var body: some View {
        TimelineView(.animation(paused: isPaused)) { context in
            GeometryReader { geometry in
                StrokeAnimatableShape(
                    animationProgress: animationProgress,
                    shape: shape
                )
                    .stroke(lineColor, lineWidth: lineWidth)
                    .aspectRatio(shapeAspectRatio, contentMode: .fit)
                    .frame(width: geometry.size.width, alignment: .center)
                    .onChange(of: context.date) { oldValue, newValue in
                        if lastFrameDate == nil {
                            lastFrameDate = newValue
                        } else {
                            let deltaTime = newValue.timeIntervalSince(oldValue)
                            animationProgress += deltaTime / CGFloat(duration.components.seconds)
                        }
                    }
                    .onChange(of: isPaused) { oldValue, newValue in
                        lastFrameDate = nil
                    }
            }
        }
    }
}
