//
//  StrokeAnimationViewModel.swift
//  SymbolKit
//
//  Created by yugo.sugiyama on 2025/01/22.
//

import Foundation
import Observation

@Observable
public class StrokeAnimationViewModel {

    private(set) var animationProgress: CGFloat = 0
    private(set) var fromAnimationProgress: CGFloat = 0
    private(set) var toAnimationProgress: CGFloat = 0
    let animationType: PathAnimationType

    public init(animationType: PathAnimationType = .progressiveDraw) {
        self.animationType = animationType
        if case let .fixedRatioMove(strokeLengthRatio) = animationType {
            fromAnimationProgress = -strokeLengthRatio
        }
    }

    func addProgress(progress: CGFloat) {
        switch animationType {
        case .progressiveDraw:
            animationProgress += progress
        case .fixedRatioMove:
            fromAnimationProgress += progress
            toAnimationProgress += progress
        }
    }

    func resetProgress() {
        switch animationType {
        case .progressiveDraw:
            animationProgress = 0
        case .fixedRatioMove(let strokeLengthRatio):
            fromAnimationProgress = -strokeLengthRatio
            toAnimationProgress = 0
        }
    }
}
