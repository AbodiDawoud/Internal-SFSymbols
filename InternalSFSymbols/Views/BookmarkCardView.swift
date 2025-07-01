//
//  BookmarkRowView.swift
//  InternalSFSymbols
    

import SwiftUI

struct BookmarkCardView: View {
    private let symbolName: String
    private let theme: [Color] = [.indigo, .blue, .cyan]


    init(_ symbolName: String) {
        self.symbolName = symbolName
    }
        
    var body: some View {
        VStack(spacing: 0) {
            Image(_internalSystemName: symbolName)
                .font(.system(size: 46))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
                .shadow(color: .gray, radius: 15)
                .bold()
                .frame(height: 160)
                .background {
                    HStack {
                        Circle()
                            .fill(theme[0]).frame(width: 130).blur(radius: 65)
                        
                        Circle()
                            .fill(theme[1]).frame(width: 260).blur(radius: 115)

                        Circle()
                            .fill(theme[2]).frame(width: 130).blur(radius: 65)
                    }
                }
                .frame(maxWidth: .infinity)
                .compositingGroup()

                
            Divider()
            
            
            Text(symbolName)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .lineLimit(1, reservesSpace: true)
                .padding([.horizontal, .bottom], 13)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
        }
        .frame(width: 300)
        .cornerRadius(12)
    }
}
