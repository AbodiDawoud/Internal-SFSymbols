//
//  SymbolEditorView.swift
//  InternalSFSymbols
//

import SwiftUI
import UIKit

struct SymbolEditorView: View {
    let symbolName: String
    let showsCodeLineNumbers: Bool
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var bookmarks: Bookmarks
    
    @State private var accentColor: Color = .primary
    @State private var secondaryColor: Color = .blue
    @State private var symbolVariant: SymbolVariants = .none
    @State private var symbolWeight: Font.Weight = .regular
    @State private var symbolScele: Image.Scale = .medium
    @State private var usesDefaultAccentColor: Bool = true
    @State private var usesDefaultSecondaryColor: Bool = true
    
    @AppStorage("symbol_rendering_mode") private var renderingMode: String = "monochrome"

    init(symbolName: String, showsCodeLineNumbers: Bool = true) {
        self.symbolName = symbolName
        self.showsCodeLineNumbers = showsCodeLineNumbers
    }
 
    var body: some View {
        NavigationStack {
            List {
                Section {
                    symbolPreview
                }
                
                SymbolEditorActionBar(
                    symbolName,
                    content: AnyView(symbolContent) // used to save or share the symbol
                )

                Section {
                    Picker("Rendering Mode", selection: $renderingMode.animation()) {
                        Text("Hierarchical").tag("hierarchical")
                        Text("Monochrome").tag("monochrome")
                        Text("MultiColor").tag("multicolor")
                        Text("Palette").tag("palette")
                    }
                    
                    ColorPicker("Accent Color", selection: accentColorBinding)
                    
                    if renderingMode == "palette" {
                        ColorPicker("Secondary Color", selection: secondaryColorBinding)
                    }
                }
                .frame(maxHeight: 33)
                
                Section {
                    Picker("Variants", selection: $symbolVariant.animation()) {
                        Text("None").tag(SymbolVariants.none)
                        Text("Fill").tag(SymbolVariants.fill)
                        Text("Circle").tag(SymbolVariants.circle)
                        Text("Rectangle").tag(SymbolVariants.rectangle)
                        Text("Slash").tag(SymbolVariants.slash)
                        Text("Square").tag(SymbolVariants.square)
                    }
                    
                    Picker("Scale", selection: $symbolScele.animation()) {
                        Text("Small").tag(Image.Scale.small)
                        Text("Medium").tag(Image.Scale.medium)
                        Text("Large").tag(Image.Scale.large)
                    }
                    
                    Picker("Weight", selection: $symbolWeight.animation()) {
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
                }
                
                Section {
                    SymbolCodePreview(
                        symbolName: symbolName,
                        renderingMode: renderingMode,
                        symbolVariant: symbolVariant,
                        symbolWeight: symbolWeight,
                        symbolScale: symbolScele,
                        accentColor: accentColor,
                        secondaryColor: secondaryColor,
                        usesDefaultAccentColor: usesDefaultAccentColor,
                        usesDefaultSecondaryColor: usesDefaultSecondaryColor,
                        showsLineNumbers: showsCodeLineNumbers
                    )
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Symbol Editor")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: setNavigationAppearance)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                        .tint(.gray)
                        .fontWeight(.medium)
                        .controlSize(.small)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        bookmarks.toggleBookmark(for: symbolName)
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        Image(systemName: bookmarks.isBookmarked(symbolName) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(.orange)
                            .font(.footnote.weight(.medium))
                            .padding(7)
                            .background(Color(white: scheme == .light ? 0.94 : 0.2), in: .circle)
                            .animation(.smooth, value: bookmarks.isBookmarked(symbolName))
                            .contentTransition(.symbolEffect(.replace.upUp, options: .default))
                    }
                }
            }
            .persistentSystemOverlays(.hidden)
        }
    }

    private var symbolPreview: some View {
        VStack {
            Image(_internalSystemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 55, height: 55)
                .symbolRenderingMode(renderingMode.toRenderingMode())
                .symbolVariant(symbolVariant)
                .foregroundStyle(accentColor, secondaryColor)
                .fontWeight(symbolWeight)
                .imageScale(symbolScele)
                .padding(25)
                .background(Color.gray.opacity(0.2), in: .rect(cornerRadius: 20))
            
            Text(symbolName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }

    // This is the saveable and shareable symbol version.
    // We cant use "symbolPreview" view because it contains some unnecessary text and modifiers.
    var symbolContent: some View {
        Image(_internalSystemName: symbolName)
            .resizable()
            .scaledToFit()
            .frame(width: 512, height: 512)
            .symbolRenderingMode(renderingMode.toRenderingMode())
            .symbolVariant(symbolVariant)
            .fontWeight(symbolWeight)
            .imageScale(symbolScele)
            .foregroundStyle(accentColor, secondaryColor)
    }
    
    private var accentColorBinding: Binding<Color> {
        Binding(
            get: { accentColor },
            set: { newValue in
                accentColor = newValue
                usesDefaultAccentColor = false
            }
        )
    }
    
    private var secondaryColorBinding: Binding<Color> {
        Binding(
            get: { secondaryColor },
            set: { newValue in
                secondaryColor = newValue
                usesDefaultSecondaryColor = false
            }
        )
    }

    func setNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.systemGray4

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
