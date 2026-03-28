//
//  SymbolCodePreview.swift
//  InternalSFSymbols
//

import SwiftUI
import UIKit

struct SymbolCodePreview: View {
    let symbolName: String
    let renderingMode: String
    let symbolVariant: SymbolVariants
    let symbolWeight: Font.Weight
    let symbolScale: Image.Scale
    let accentColor: Color
    let secondaryColor: Color
    let usesDefaultAccentColor: Bool
    let usesDefaultSecondaryColor: Bool
    var showsLineNumbers: Bool = true
    
    @State private var animateCopyAction: Bool = false

    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Button(action: copyCodePreview) {
                    Image(systemName: animateCopyAction ? "checkmark" : "square.on.square")
                        .font(.caption.weight(.semibold))
                        .symbolRenderingMode(.hierarchical)
                        .frame(width: 20)
                }
                .buttonStyle(.plain)
                .foregroundStyle(animateCopyAction ? .green : .primary)
                .animation(.linear, value: animateCopyAction)
                .contentTransition(.symbolEffect)
                .padding(.leading, 7)
                
                Divider().frame(height: 12)
                
                Text("Code Preview")
                    .font(.callout.weight(.medium))
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(codeLines.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            if showsLineNumbers {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundStyle(codeLineNumberColor)
                                    .frame(width: 26, alignment: .trailing)
                            }
                            
                            line
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: true, vertical: true)
                .textSelection(.enabled)
            }
            .padding([.trailing, .vertical], 14)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    //.strokeBorder(codePreviewBorderColor, lineWidth: 1)
                    .fill(codePreviewBackgroundColor)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var codeLines: [Text] {
        [
            imageDeclarationLine,
            modifierLine("resizable"),
            modifierLine("scaledToFit"),
            modifierLine("symbolRenderingMode", argument: enumValue(renderingMode.swiftRenderingModeLiteral)),
            modifierLine("symbolVariant", argument: enumValue(symbolVariant.swiftSourceLiteral)),
            modifierLine("fontWeight", argument: enumValue(symbolWeight.swiftSourceLiteral)),
            modifierLine("imageScale", argument: enumValue(symbolScale.swiftSourceLiteral)),
            modifierLine("foregroundStyle", argument: foregroundStylePreviewText)
        ]
    }
    
    private var imageDeclarationLine: Text {
        typeToken("Image")
        + punctuationToken("(")
        + labelToken("_internalSystemName")
        + punctuationToken(": ")
        + stringToken("\"\(symbolName.swiftEscaped)\"")
        + punctuationToken(")")
    }
    
    private func modifierLine(_ name: String, argument: Text? = nil) -> Text {
        let suffix = if let argument {
            punctuationToken("(") + argument + punctuationToken(")")
        } else {
            punctuationToken("()")
        }
        
        return plainToken("    ")
        + punctuationToken(".")
        + modifierToken(name)
        + suffix
    }
    
    private var foregroundStylePreviewText: Text {
        if renderingMode == "palette" {
            return colorPreviewText(for: accentColor, defaultToken: usesDefaultAccentColor ? ".primary" : nil)
            + punctuationToken(", ")
            + colorPreviewText(for: secondaryColor, defaultToken: usesDefaultSecondaryColor ? ".blue" : nil)
        }
        
        return colorPreviewText(for: accentColor, defaultToken: usesDefaultAccentColor ? ".primary" : nil)
    }
    
    private func colorPreviewText(for color: Color, defaultToken: String?) -> Text {
        if let defaultToken {
            return enumValue(defaultToken)
        }
        
        let components = UIColor(color).rgbaComponents
        
        return typeToken("Color")
        + punctuationToken("(")
        + labelToken("red")
        + punctuationToken(": ")
        + numberToken(components.red.swiftComponentLiteral)
        + punctuationToken(", ")
        + labelToken("green")
        + punctuationToken(": ")
        + numberToken(components.green.swiftComponentLiteral)
        + punctuationToken(", ")
        + labelToken("blue")
        + punctuationToken(": ")
        + numberToken(components.blue.swiftComponentLiteral)
        + punctuationToken(", ")
        + labelToken("opacity")
        + punctuationToken(": ")
        + numberToken(components.alpha.swiftComponentLiteral)
        + punctuationToken(")")
    }
    
    private func copyCodePreview() {
        if animateCopyAction { return }
        
        UIPasteboard.general.string = codePreviewSource
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        animateCopyAction = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            animateCopyAction = false
        }
    }
    
    private var codePreviewSource: String {
        let foregroundStyleLine: String
        
        if renderingMode == "palette" {
            foregroundStyleLine = "    .foregroundStyle(\(swiftColorSource(for: accentColor, defaultToken: usesDefaultAccentColor ? ".primary" : nil)), \(swiftColorSource(for: secondaryColor, defaultToken: usesDefaultSecondaryColor ? ".blue" : nil)))"
        } else {
            foregroundStyleLine = "    .foregroundStyle(\(swiftColorSource(for: accentColor, defaultToken: usesDefaultAccentColor ? ".primary" : nil)))"
        }
        
        return [
            "Image(_internalSystemName: \"\(symbolName.swiftEscaped)\")",
            "    .resizable()",
            "    .scaledToFit()",
            "    .symbolRenderingMode(\(renderingMode.swiftRenderingModeLiteral))",
            "    .symbolVariant(\(symbolVariant.swiftSourceLiteral))",
            "    .fontWeight(\(symbolWeight.swiftSourceLiteral))",
            "    .imageScale(\(symbolScale.swiftSourceLiteral))",
            foregroundStyleLine
        ]
        .joined(separator: "\n")
    }
    
    private func swiftColorSource(for color: Color, defaultToken: String?) -> String {
        if let defaultToken {
            return defaultToken
        }
        
        let components = UIColor(color).rgbaComponents
        
        return "Color(red: \(components.red.swiftComponentLiteral), green: \(components.green.swiftComponentLiteral), blue: \(components.blue.swiftComponentLiteral), opacity: \(components.alpha.swiftComponentLiteral))"
    }
    
    private func plainToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codePlainTextColor)
    }
    
    private func punctuationToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codePlainTextColor)
    }
    
    private func typeToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeTypeColor)
    }
    
    private func modifierToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeModifierColor)
    }
    
    private func labelToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeLabelColor)
    }
    
    private func stringToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeStringColor)
    }
    
    private func numberToken(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeNumberColor)
    }
    
    private func enumValue(_ value: String) -> Text {
        Text(verbatim: value).foregroundColor(codeMemberColor)
    }
    
    private var codePreviewBackgroundColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.systemGray5
            }
            
            return UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        })
    }
    
    private var codePreviewBorderColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.04)
            }
            
            return UIColor.black.withAlphaComponent(0.03)
        })
    }
    
    private var codePlainTextColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.89, green: 0.91, blue: 0.95, alpha: 1)
            }
            
            return UIColor(red: 0.14, green: 0.16, blue: 0.19, alpha: 1)
        })
    }
    
    private var codeTypeColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.46, green: 0.74, blue: 0.98, alpha: 1)
            }
            
            return UIColor(red: 0.09, green: 0.36, blue: 0.82, alpha: 1)
        })
    }
    
    private var codeModifierColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.80, green: 0.56, blue: 0.98, alpha: 1)
            }
            
            return UIColor(red: 0.56, green: 0.21, blue: 0.82, alpha: 1)
        })
    }
    
    private var codeLabelColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.67, green: 0.70, blue: 0.76, alpha: 1)
            }
            
            return UIColor(red: 0.44, green: 0.47, blue: 0.53, alpha: 1)
        })
    }
    
    private var codeStringColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.98, green: 0.53, blue: 0.46, alpha: 1)
            }
            
            return UIColor(red: 0.78, green: 0.22, blue: 0.18, alpha: 1)
        })
    }
    
    private var codeNumberColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.99, green: 0.77, blue: 0.39, alpha: 1)
            }
            
            return UIColor(red: 0.74, green: 0.42, blue: 0.10, alpha: 1)
        })
    }
    
    private var codeMemberColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.58, green: 0.84, blue: 0.98, alpha: 1)
            }
            
            return UIColor(red: 0.00, green: 0.46, blue: 0.66, alpha: 1)
        })
    }
    
    private var codeLineNumberColor: Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.40, green: 0.45, blue: 0.52, alpha: 1)
            }
            
            return UIColor(red: 0.53, green: 0.56, blue: 0.61, alpha: 1)
        })
    }
}
