//
//  TextShape.swift
//  SymbolKit
//
//  Created by Yugo Sugiyama on 2025/01/05.
//

import SwiftUI

public enum TextAnimationOrder {
    case standard
    case random
    case shuffled(indices: [Int])
}

public struct TextPathShape: Shape {
    let text: String
    let font: AppFont
    private let indices: [Int]

    public init(_ text: String, font: AppFont? = .singlePathLineFont(), textAnimationOrder: TextAnimationOrder = .standard) {
        let adjustedText = text.replacingOccurrences(of: " ", with: "")
        self.text = adjustedText
        self.font = font!
        switch textAnimationOrder {
        case .standard:
            indices = adjustedText.enumerated().map(\.offset)
        case .random:
            indices = Array(0...adjustedText.count - 1).shuffled()
        case .shuffled(let indices):
            self.indices = indices
        }
    }

    public func path(in rect: CGRect) -> Path {
        var combinedPath = Path()

        // Core Textフォントの作成
        let ctFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)

        // 文字列とフォントの属性付き文字列を作成
        let attributedString = NSAttributedString(string: text, attributes: [.font: ctFont])

        // 属性付き文字列からCTLineを作成
        let line = CTLineCreateWithAttributedString(attributedString)

        // CTLineからグリフランを取得
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        // グリフパスと位置を保持
        var glyphPaths: [(Path, CGPoint)] = []
        for run in runs {
            for i in 0..<CTRunGetGlyphCount(run) {
                var glyph: CGGlyph = 0
                var position = CGPoint()
                CTRunGetGlyphs(run, CFRangeMake(i, 1), &glyph)
                CTRunGetPositions(run, CFRangeMake(i, 1), &position)

                // 各グリフのパスを作成し、結合
                if let letterPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
                    let glyphPath = Path(letterPath)
                    glyphPaths.append((glyphPath, position))
                }
            }
        }

        // indicesに基づいてグリフの順序を決定
        let orderedPaths = indices.map { glyphPaths[$0] }

        // ランダムな順番でグリフを結合
        for (glyphPath, position) in orderedPaths {
            let transform = CGAffineTransform(translationX: position.x, y: position.y)
            combinedPath.addPath(glyphPath.applying(transform))
        }

        // テキストの表示領域にスケーリング
        let boundingBox = combinedPath.boundingRect
        let scaleX = rect.width / boundingBox.width
        let scaleY = rect.height / boundingBox.height
        let scale = min(scaleX, scaleY)

        // 上下反転の修正とオフセット調整
        let offsetX = (rect.width - boundingBox.width * scale) / 2 - boundingBox.minX * scale
        let offsetY = (rect.height + boundingBox.height * scale) / 2 + boundingBox.minY * scale
        let transform = CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: -scale)

        return combinedPath.applying(transform)
    }
}

private extension AppFont {
    var cgFont: CGFont? {
        return CGFont(self.fontName as CFString)
    }
}
