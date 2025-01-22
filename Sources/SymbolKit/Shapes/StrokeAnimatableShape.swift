//
//  StrokeAnimatableShape.swift
//  SymbolKit
//
//  Created by yugo.sugiyama on 2025/01/22.
//

import SwiftUI

public struct StrokeAnimatableShape {
    public var animationProgress: CGFloat = 0
    public let shape: any Shape

    public init(animationProgress: CGFloat, shape: any Shape) {
        self.animationProgress = animationProgress
        self.shape = shape
    }
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
