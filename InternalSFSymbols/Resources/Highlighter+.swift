//
//  Highlighter+.swift
//  InternalSFSymbols
    

import SwiftUI

extension String {
    var swiftRenderingModeLiteral: String {
        switch lowercased() {
        case "hierarchical": ".hierarchical"
        case "monochrome": ".monochrome"
        case "multicolor": ".multicolor"
        case "palette": ".palette"
        default: ".monochrome"
        }
    }
    
    var swiftEscaped: String {
        replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }
}

extension Font.Weight {
    var swiftSourceLiteral: String {
        switch self {
        case .black: ".black"
        case .heavy: ".heavy"
        case .bold: ".bold"
        case .semibold: ".semibold"
        case .medium: ".medium"
        case .regular: ".regular"
        case .light: ".light"
        case .thin: ".thin"
        case .ultraLight: ".ultraLight"
        default: ".regular"
        }
    }
}

extension Image.Scale {
    var swiftSourceLiteral: String {
        switch self {
        case .small: ".small"
        case .medium: ".medium"
        case .large: ".large"
        @unknown default: ".medium"
        }
    }
}

extension SymbolVariants {
    var swiftSourceLiteral: String {
        switch self {
        case .none: ".none"
        case .fill: ".fill"
        case .circle: ".circle"
        case .rectangle: ".rectangle"
        case .slash: ".slash"
        case .square: ".square"
        default: ".none"
        }
    }
}

extension UIColor {
    var rgbaComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red, green, blue, alpha)
        }
        
        return (.zero, .zero, .zero, 1)
    }
}

extension CGFloat {
    var swiftComponentLiteral: String {
        String(format: "%.3f", self)
    }
}
