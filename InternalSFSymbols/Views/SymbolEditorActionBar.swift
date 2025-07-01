//
//  SymbolPreviewActionBar.swift
//  InternalSFSymbols
    

import SwiftUI

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
                Button("", systemImage: shouldAnimateCopyAction ? "checkmark" : "doc.on.doc", action: copySymbolName)
                    .foregroundStyle(shouldAnimateCopyAction ? .green : .primary)
                    .animation(.linear, value: shouldAnimateCopyAction)
                Spacer()
                
                Divider()
                Spacer()
                
                Button("", systemImage: shouldAnimateSaveAction ? "checkmark" : "tray.and.arrow.down", action: saveSymbolToPhotoLibrary)
                    .foregroundStyle(shouldAnimateSaveAction ? .green : .primary)
                    .animation(.linear, value: shouldAnimateSaveAction)
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
        
        // Im unwrapping it because im 99% sure it returns a valid image.
        let imageToSave = ImageRenderer(content: symbolContent).uiImage!
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        shouldAnimateSaveAction.toggle()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            shouldAnimateSaveAction.toggle()
        }
    }
    
    func symbolToTemporaryURL() -> URL {
        let uiImage = ImageRenderer(content: symbolContent).uiImage!
        let data = uiImage.pngData()!

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(symbolName).png")
        try? data.write(to: tempURL)
        return tempURL
    }
}
