//
//  BookmarkManager.swift
//  InternalSFSymbols
    

import SwiftUI


class Bookmarks: ObservableObject {    
    private let userDefaults: UserDefaults = .standard
    private let userDefaultsKey: String = "bookmarks"
    
    @Published var bookmarks: [String] = []
    
    
    init() {
        loadBookmarks()
    }
    
    func toggleBookmark(for symbolName: String) {
        if bookmarks.contains(symbolName) {
            removeBookmark(symbolName)
        } else {
            addBookmark(symbolName)
        }
    }
    
    func addBookmark(_ symbolName: String) {
        bookmarks.insert(symbolName, at: 0)
        userDefaults.set(bookmarks, forKey: userDefaultsKey)
    }
    
    func removeBookmark(_ symbolName: String) {
        bookmarks.removeAll { $0 == symbolName }
        userDefaults.set(bookmarks, forKey: userDefaultsKey)
    }
    
    func removeBookmark(_ index: IndexSet) {
        for i in index {
            bookmarks.remove(at: i)
        }
        
        userDefaults.set(bookmarks, forKey: userDefaultsKey)
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        userDefaults.removeObject(forKey: userDefaultsKey)
    }
    
    func loadBookmarks()  {
        if let savedBookmarks = userDefaults.array(forKey: userDefaultsKey) as? [String] {
            bookmarks = savedBookmarks
        }
    }
    
    func isBookmarked(_ symbolName: String) -> Bool {
        bookmarks.contains(symbolName)
    }
    
    func recentBookmarks(upTo limit: Int = 3) -> [String] {
        Array(bookmarks.prefix(limit))
    }
    
    var totalBookmarks: String {
        String(bookmarks.count)
    }
    
    var isBookmarksEmpty: Bool {
        bookmarks.isEmpty
    }
}
