//
//  SymbolsManager.swift
//  InternalSFSymbols
    

import Foundation


/// Responsible for loading all internal symbols
class SymbolsManager {
    private var assetManager: NSObject
    private(set) var symbols: [String]
    
    var totalSymbols: String { String(symbols.count) }
    
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
        let symbolsToExclude = ["_gradient.highlegibility"] // invalid symbols
        
        self.symbols = allSymbols.replacing(symbolsToExclude, with: [])
    }
}
