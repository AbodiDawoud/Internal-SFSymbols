//
//  ContentView.swift
//  InternalSFSymbols
    

import SwiftUI

struct ContentView: View {
    private let symbolManager = SymbolsManager()
    @EnvironmentObject private var bookmarksManager: Bookmarks
    
    @State private var searchText: String = ""
    @State private var tappedSymbol: String?
    @State private var bookmarksRefreshID: UUID? // This id used to update the UI when a new bookmark inserted or removed.
    
    @AppStorage("symbol_rendering_mode") private var renderingMode: String = "monochrome"
    @AppStorage("has_seen_cardView") private var hasSeenCardView: Bool = false
    @SceneStorage("color_scheme") private var color_scheme: String = "dark"
    
    
    var body: some View {
        List {
            if hasSeenCardView == false {
                Section {
                    cardView
                }
            }
 
            if !bookmarksManager.isBookmarksEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(bookmarksManager.recentBookmarks(upTo: 3)) { bookmark in
                                BookmarkCardView(bookmark).onTapGesture {
                                    tappedSymbol = bookmark
                                }
                            }
                        }
                    }
                    .id(bookmarksRefreshID)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                } header: {
                    NavigationLink {
                        BookmarksView().environmentObject(bookmarksManager)
                    } label: {
                        HStack {
                            Text("Bookmarks")
                            Image(systemName: "chevron.right")
                        }.bold()
                    }.buttonStyle(.plain)
                }
            }

            
            ForEach(filtreredSymbols) {
                symbolRow(symbol: $0)
            }
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
            
            ToolbarItem(placement: .topBarTrailing) { colorSchemeButton }
        }
        .scrollDismissesKeyboard(.interactively)
        .preferredColorScheme(color_scheme.toColorScheme())
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $tappedSymbol) {
            SymbolEditorView(symbolName: $0)
        }
        .onChange(of: bookmarksManager.bookmarks, perform: { _ in
            bookmarksRefreshID = UUID()
        })
    }
    
    var filtreredSymbols: [String] {
        if searchText.isEmpty {
            return symbolManager.symbols
        }
        
        return symbolManager.symbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    
    private var cardView: some View {
        Image("foundations-sf")
            .resizable()
            .scaledToFit()
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .overlay(alignment: .bottom) {
                HStack {
                    Text("Human Interface ")
                        .font(.callout)
                        .opacity(0.9)
                    
                    Image(systemName: "arrow.up.right")
                        .imageScale(.small)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 7.8)
                .padding(.horizontal, 15)
                .background(.regularMaterial)
                .onTapGesture {
                    let url = URL(string: "https://developer.apple.com/design/human-interface-guidelines/sf-symbols")!
                    UIApplication.shared.open(url)
                }
            }
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
    
    
    private var colorSchemeButton: some View {
        Button {
            color_scheme = color_scheme == "light" ? "dark" : "light"
        } label: {
            Image(systemName: color_scheme == "light" ? "moon" : "sun.min")
        }
        .buttonStyle(.plain)
    }
}
