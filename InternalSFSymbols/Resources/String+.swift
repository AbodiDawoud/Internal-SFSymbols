//
//  String+.swift
//  InternalSFSymbols
    

import SwiftUI


extension String: @retroactive Identifiable {
    // Im doing this to be able to bind on strings like:
    // .sheet(item: $tappedSymbol)
    public var id: Self { self }
}


extension String {
    func toRenderingMode() -> SymbolRenderingMode {
        // We cannot bind SymbolRenderingMode to a PickerView eg.Picker(selection: $renderingMode), therefore we use this helper method.
        return switch self.lowercased() {
        case "hierarchical": SymbolRenderingMode.hierarchical
        case "monochrome": SymbolRenderingMode.monochrome
        case "multicolor": SymbolRenderingMode.multicolor
        case "palette": SymbolRenderingMode.palette
        
        default: SymbolRenderingMode.hierarchical
        }
    }
}


extension String {
    /// Convert a string into `ColorScheme`object.
    func toColorScheme() -> ColorScheme? {
        return switch self.lowercased() {
        case "light": .light
        case "dark": .dark
            
        default: nil // defaults to system
        }
    }
}
