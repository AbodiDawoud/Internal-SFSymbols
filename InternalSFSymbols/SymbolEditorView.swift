//
//  SymbolEditorView.swift
//  InternalSFSymbols
    

import SwiftUI
 

struct SymbolEditorView: View {
    let symbolName: String
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var accentColor: Color = .primary
    @State private var secondaryColor: Color = .blue
    
    @State private var renderingMode: String
    @State private var symbolVariants: SymbolVariants = .none
    @State private var symbolWeight: Font.Weight = .regular
    @State private var symbolScele: Image.Scale = .medium
    
    @State private var shouldAnimateCopyAction: Bool = false
    @State private var shouldAnimateSaveAction: Bool = false

    
    init(symbolName: String, rnMode: String) {
        self.symbolName = symbolName
        self._renderingMode = .init(initialValue: rnMode)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    symbolPreview
                }.frame(maxWidth: .infinity).listRowBackground(Color.clear)
                
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
                
                Section {
                    ColorPicker("Accent Color", selection: $accentColor)
                    
                    if renderingMode == "palette" {
                        ColorPicker("Secondary Color", selection: $secondaryColor)
                    }
                    
                    Picker("Rendering Mode", selection: $renderingMode.animation()) {
                        Text("Hierarchical").tag("hierarchical")
                        Text("Monochrome").tag("monochrome")
                        Text("MultiColor").tag("multicolor")
                        Text("Palette").tag("palette")
                    }
                }.frame(maxHeight: 33)
                
                Section {
                    Picker("Symbol Variants", selection: $symbolVariants.animation()) {
                        Text("None").tag(SymbolVariants.none)
                        Text("Fill").tag(SymbolVariants.fill)
                        Text("Circle").tag(SymbolVariants.circle)
                        Text("Rectangle").tag(SymbolVariants.rectangle)
                        Text("Slash").tag(SymbolVariants.slash)
                        Text("Square").tag(SymbolVariants.square)
                    }   
                    
                    Picker("Symbol Scale", selection: $symbolScele.animation()) {
                        Text("Small").tag(Image.Scale.small)
                        Text("Medium").tag(Image.Scale.medium)
                        Text("Large").tag(Image.Scale.large)
                    } 
                    
                    Picker("Symbol Weight", selection: $symbolWeight.animation()) {
                        Text("Black").tag(Font.Weight.black)
                        Text("Heavy").tag(Font.Weight.heavy)
                        Text("Bold").tag(Font.Weight.bold)
                        Text("SemiBold").tag(Font.Weight.semibold)
                        Text("Medium").tag(Font.Weight.medium)
                        Text("Regular").tag(Font.Weight.regular)
                        Text("Light").tag(Font.Weight.light)
                        Text("Thin").tag(Font.Weight.thin)
                        Text("UltraLight").tag(Font.Weight.ultraLight)
                    }
                }.frame(maxHeight: 33)
            }
            .navigationTitle("Symbol Editor")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: setNavigationAppearance)
            .toolbar {
                Button("Done", action: dismiss.callAsFunction)
                    .tint(.gray)
                    .fontWeight(.medium)
                    .controlSize(.small)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
            }
        }
    }
    
    
    private var symbolPreview: some View {
        VStack {
            Image(_internalSystemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .symbolRenderingMode(renderingMode.toRenderingMode())
                .symbolVariant(symbolVariants)
                .foregroundStyle(accentColor, secondaryColor)
                .fontWeight(symbolWeight)
                .imageScale(symbolScele)
                .padding(25)
                .background(Color.gray.opacity(0.2), in: .rect(cornerRadius: 6))
            
            Text(symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
    }

    
    // This is the saveable and shareable symbol version.
    // We cant use "symbolPreview" instance because it contains some unnecessary text and modifiers.
    var symbolContent: some View {
        Image(_internalSystemName: symbolName)
            .resizable()
            .scaledToFit()
            .frame(width: 512, height: 512)
            .symbolRenderingMode(renderingMode.toRenderingMode())
            .symbolVariant(symbolVariants)
            .fontWeight(symbolWeight)
            .imageScale(symbolScele)
            .foregroundStyle(accentColor, secondaryColor)
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
        
        // Im unwrapping it because im 99% sure it returns a valid value.
        let imageToSave = ImageRenderer(content: symbolContent).uiImage!
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        
        shouldAnimateSaveAction.toggle()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            shouldAnimateSaveAction.toggle()
        }
    }

    func setNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.systemGray4

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    func symbolToTemporaryURL() -> URL {
        let uiImage = ImageRenderer(content: symbolContent).uiImage!
        let data = uiImage.pngData()!

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(symbolName).png")
        try? data.write(to: tempURL)
        return tempURL
    }
}
