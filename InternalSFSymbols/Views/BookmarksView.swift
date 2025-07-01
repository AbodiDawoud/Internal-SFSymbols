//
//  BookmarksView.swift
//  InternalSFSymbols
    

import SwiftUI

struct BookmarksView: View {
    @AppStorage("symbol_rendering_mode") private var renderingMode: String!
    @EnvironmentObject private var bookmarksManager: Bookmarks
    @State private var tappedSymbol: String?
    
    
    var body: some View {
        List {
            ForEach(bookmarksManager.bookmarks) {
                symbolRow($0)
            }
            .onDelete(perform: bookmarksManager.removeBookmark)
        }
        .navigationTitle("Bookmarks")
        .sheet(item: $tappedSymbol) {
            SymbolEditorView(symbolName: $0)
        }
    }
    
    private func symbolRow(_ symbol: String) -> some View {
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
}

#Preview {
    BookmarksView()
}
