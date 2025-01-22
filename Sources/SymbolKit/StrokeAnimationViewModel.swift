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

    public init() {
    }

    func updateProgress(progress: CGFloat) {
        animationProgress = progress
    }

    func resetProgress() {
        animationProgress = 0
    }
}
