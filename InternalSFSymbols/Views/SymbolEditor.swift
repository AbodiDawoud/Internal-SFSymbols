//
//  SymbolEditorView.swift
//  InternalSFSymbols
    

import SwiftUI
 

struct SymbolEditorView: View {
    let symbolName: String
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var accentColor: Color = .primary
    @State private var secondaryColor: Color = .blue
    
    @State private var symbolVariant: SymbolVariants = .none
    @State private var symbolWeight: Font.Weight = .regular
    @State private var symbolScele: Image.Scale = .medium
    
    @EnvironmentObject private var bookmarks: Bookmarks
    @AppStorage("symbol_rendering_mode") private var renderingMode: String!


    init(symbolName: String) {
        self.symbolName = symbolName
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
                    
                    ColorPicker("Accent Color", selection: $accentColor)
                    
                    if renderingMode == "palette" {
                        ColorPicker("Secondary Color", selection: $secondaryColor)
                    }
                }.frame(maxHeight: 33)
                
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
                }.frame(maxHeight: 33)
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
                    } label: {
                        Image(systemName: bookmarks.isBookmarked(symbolName) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(.orange)
                            .font(.footnote.weight(.medium))
                            .padding(7)
                            .background(Color.gray.opacity(0.2), in: .circle)
                            .animation(.smooth, value: bookmarks.isBookmarked(symbolName))
                            .backport {
                                if #available(iOS 17.0, *) {
                                    $0.contentTransition(.symbolEffect(.replace.upUp, options: .default))
                                }
                            }
                    }
                }
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

    func setNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.systemGray4

        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
