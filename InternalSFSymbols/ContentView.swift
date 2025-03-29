//
//  ContentView.swift
//  InternalSFSymbols
    

import SwiftUI

struct ContentView: View {
    @SceneStorage("symbol_rendering_mode") private var renderingMode: String = "multicolor"
    @State private var searchText: String = ""
    @State private var tappedSymbol: String?
    
    private let symbolManager = InternalSymbolsManager()

    
    var body: some View {
        List {
            Section {
                cardView
            }
            
            ForEach(filtreredSymbols) {
                symbolRow(symbol: $0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $tappedSymbol) {
            SymbolEditorView(symbolName: $0)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Internal SFSymbols")
                        .font(.headline)
                    Text(symbolManager.totalSymbols)
                        .font(.footnote)
                        .foregroundColor(.gray)
                } 
            }
            
            ToolbarItem(placement: .topBarLeading) { renderingModePicker }
        }
    }
    
    @ViewBuilder
    private var cardView: some View {
        Image("foundations-sf")
            .resizable()
            .scaledToFit()
            .listRowInsets(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
        
        DisclosureGroup("More Info") {
            Text("This application gives you access to Apple’s internal system symbols. These symbols are not accessible through the public SFSymbols application nor are they permitted to be used by developers.")
                .padding(.leading, -20)
                .font(.callout)
                .foregroundStyle(.secondary)
        }.tint(.yellow).listRowSeparator(.hidden)
    }
    
    private func symbolRow(symbol: String) -> some View {
        HStack(spacing: 15) {
            Image(_internalSystemName: symbol)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .symbolRenderingMode(renderingMode.toRenderingMode())
            
            Text(symbol)
        }
        .onTapGesture { tappedSymbol = symbol }
    }
    
    private var renderingModePicker: some View {
        Menu {
            Text("Rendering Mode")
            Picker("", selection: $renderingMode.animation()) {
                Text("Hierarchical").tag("hierarchical")
                Text("Monochrome").tag("monochrome")
                Text("MultiColor").tag("multicolor")
                Text("Palette").tag("palette")
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: "camera.filters")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
        }.tint(.primary)
    }
    
    var filtreredSymbols: [String] {
        if searchText.isEmpty {
            return symbolManager.allImageNames
        }
        
        return symbolManager.allImageNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
}
