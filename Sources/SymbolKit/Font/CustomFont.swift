//
//  Font.swift
//  SymbolKit
//
//  Created by Yugo Sugiyama on 2025/01/05.
//

#if os(macOS)
import AppKit
public typealias AppFont = NSFont
#elseif os(iOS)
import UIKit
public typealias AppFont = UIFont
#endif
import SwiftUI
import CoreGraphics
import CoreText

private var isFontRegistered = false
private let customFontName = "HeftyRewardSingleLine"

public extension Font {
    static func singlePathLineFont(size: CGFloat = 80) -> Font {
        if !isFontRegistered {
            try? registerFont(named: customFontName)
            isFontRegistered = true
        }
        return Font.custom(customFontName, size: size)
    }
}

public extension AppFont {
    static func singlePathLineFont(size: CGFloat = 80) -> AppFont? {
        if !isFontRegistered {
            try? registerFont(named: customFontName)
            isFontRegistered = true
        }
        return AppFont(name: customFontName, size: size)
    }
}

// Ref: https://blog.bontouch.com/news-and-insights/custom-fonts-in-a-swift-package/
public enum FontError: Swift.Error {
   case failedToRegisterFont
}

private func registerFont(named name: String) throws {
   guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: .module),
      let provider = CGDataProvider(data: asset.data as NSData),
      let font = CGFont(provider),
      CTFontManagerRegisterGraphicsFont(font, nil) else {
    throw FontError.failedToRegisterFont
   }
}
