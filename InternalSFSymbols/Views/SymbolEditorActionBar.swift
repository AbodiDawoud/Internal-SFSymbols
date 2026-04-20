//
//  SymbolPreviewActionBar.swift
//  InternalSFSymbols
    

import SwiftUI
import Photos


struct SymbolEditorActionBar: View {
    let symbolName: String
    let symbolContent: AnyView // The configured symbol view.
    
    @State private var shouldAnimateCopyAction: Bool = false
    @State private var shouldAnimateSaveAction: Bool = false
    
    init(_ symbolName: String, content: AnyView) {
        self.symbolName = symbolName
        self.symbolContent = content
    }
    
    var body: some View {
        Section {
            HStack {
                Spacer()
                Button("", systemImage: shouldAnimateCopyAction ? "checkmark" : "square.on.square.dashed", action: copySymbolName)
                    .foregroundStyle(shouldAnimateCopyAction ? .green : .primary)
                    .animation(.linear, value: shouldAnimateCopyAction)
                    .frame(width: 30)
                    .contentTransition(.symbolEffect)
                Spacer()
                
                Divider()
                Spacer()
                
                Button("", systemImage: shouldAnimateSaveAction ? "checkmark" : "tray.and.arrow.down", action: saveSymbolToPhotoLibrary)
                    .animation(.linear, value: shouldAnimateSaveAction)
                    .frame(width: 30)
                    .contentTransition(.symbolEffect)
                Spacer()
                Divider()
                
                Spacer()
                ShareLink(item: symbolToTemporaryURL()) {
                    Image(systemName: "square.and.arrow.up")
                }
                Spacer()
            }
            .symbolVariant(.fill)
            .symbolRenderingMode(.hierarchical)
            .padding(.vertical, 2)
            .buttonStyle(.plain)
            .labelStyle(.iconOnly)
            .listRowInsets(EdgeInsets())
        }
    }
    
    func copySymbolName() {
        if shouldAnimateCopyAction == true { return }
        
        UIPasteboard.general.string = symbolName
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        shouldAnimateCopyAction = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            shouldAnimateCopyAction = false
        }
    }
    
    func saveSymbolToPhotoLibrary() {
        if shouldAnimateSaveAction == true { return }
        
        let symbolURL = symbolToTemporaryURL()

        PHPhotoLibrary.shared().performChanges {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, fileURL: symbolURL, options: nil)
        } completionHandler: { success, _ in
            if success {
                cleanupTemporaryFiles()
            }
        }

        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        shouldAnimateSaveAction = true
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            shouldAnimateSaveAction = false
        }
    }
    
    func symbolToTemporaryURL() -> URL {
        let uiImage = ImageRenderer(content: symbolContent).uiImage!
        let data = uiImage.pngData()!

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(symbolName).png")
        try? data.write(to: tempURL)
        return tempURL
    }
    
    func cleanupTemporaryFiles() {
        let location = URL(fileURLWithPath: NSTemporaryDirectory())

        do {
            let content = try FileManager.default.contentsOfDirectory(at: location, includingPropertiesForKeys: nil)
            
            try content.forEach { fileURL in
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Clean up failed: \(error)")
        }
    }
}
