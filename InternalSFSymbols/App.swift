//
//  InternalSFSymbolsApp.swift
//  InternalSFSymbols
    

import SwiftUI

@main
struct InternalSFSymbolsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}



extension String: @retroactive Identifiable {
    // Im doing this to be able to bind on strings like this way:
    // .sheet(item: $tappedSymbol)
    public var id: Self { self }
    
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


// Responsible for loading all internal symbols
class InternalSymbolsManager {
    private var assetManager: NSObject
    private(set) var allImageNames: [String]
    
    var totalSymbols: String { String(allImageNames.count) }
    
    init() {
        // The bundle that contains all the private SFSymbols
        let bundle = Bundle(path: "/System/Library/CoreServices/CoreGlyphsPrivate.bundle")!
        
        // An class in UIKitCore.framework
        let UIAssetManager = NSClassFromString("_UIAssetManager") as! NSObject.Type
        
        // Initialize a new asset manager for private SFSymbols bundle
        assetManager = UIAssetManager.perform(
            NSSelectorFromString("assetManagerForBundle:"),
            with: bundle
        ).takeUnretainedValue() as! NSObject
        
        
        let allSymbols = assetManager.perform(NSSelectorFromString("_allImageNames")).takeUnretainedValue() as! [String]
        allImageNames = allSymbols.dropFirst().sorted() // We drops the first element because it's not valid
    }
}
