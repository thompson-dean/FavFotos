//
//  CompositionalLayoutView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/06.
//

import SwiftUI

struct CompositionalLayoutView<Content, Item, ID>: View where Content: View, ID: Hashable, Item: RandomAccessCollection, Item.Element: Hashable {
    var content: (Item.Element) -> Content
    var items: Item
    var id: KeyPath<Item.Element,ID>
    var spacing: CGFloat
    
    init(items: Item, id: KeyPath<Item.Element,ID>, spacing: CGFloat, @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.content = content
        self.id = id
        self.items = items
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(generateColumns(), id: \.self) { row in
              RowView(row: row)
            }
        }
    }
    
    func layoutType(row: [Item.Element]) -> LayoutType {
        let index = generateColumns().firstIndex { item in
            return item == row
        } ?? 0
        
        var types: [LayoutType] = []
        generateColumns().forEach { _ in
            if types.isEmpty {
                types.append(.type1)
            } else if types.last == .type1 {
                types.append(.type2)
            } else if types.last == .type2 {
                types.append(.type3)
            } else if types.last == .type3 {
                types.append(.type4)
            } else if types.last == .type4 {
                types.append(.type1)
            }
        }
        
        return types[index]
    }
    
    @ViewBuilder
    func RowView(row: [Item.Element]) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = (geo.size.height - spacing) / 2
            let type = layoutType(row: row)
            let columnWidth = (width > 0 ? ((width - (spacing * 2)) / 3) : 0)
            HStack(spacing: spacing) {
                if type == .type1 {
                    SafeView(row: row, index: 0)
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 1)
                            .frame(height: height)
                        SafeView(row: row, index: 2)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                }
                if type == .type2 {
                    HStack(spacing: spacing) {
                        SafeView(row: row, index: 2)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 1)
                            .frame(width: columnWidth)
                        SafeView(row: row, index: 0)
                            .frame(width: columnWidth)
                    }
                }
                if type == .type3 {
                    
                    VStack(spacing: spacing) {
                        SafeView(row: row, index: 0)
                            .frame(height: height)
                        SafeView(row: row, index: 1)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    SafeView(row: row, index: 2)
                }
                if type == .type4 {
                        HStack(spacing: spacing) {
                            SafeView(row: row, index: 2)
                                .frame(width: columnWidth)
                            SafeView(row: row, index: 1)
                                .frame(width: columnWidth)
                            SafeView(row: row, index: 0)
                                .frame(width: columnWidth)
                        }
                    }
            }
        }
        .frame(height: layoutType(row: row) == .type1 || layoutType(row: row) == .type3 ? 250 : 120)
    }
    
    @ViewBuilder
    func SafeView(row: [Item.Element], index: Int) -> some View {
        if (row.count  - 1) >= index {
            content(row[index])
        }
    }
    
    func generateColumns() -> [[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            if row.count == 3 {
                columns.append(row)
                row.removeAll()
                row.append(item)
            } else {
                row.append(item)
            }
        }
        
        columns.append(row)
        row.removeAll()
        return columns
    }
}

struct CompositionalLayoutView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

enum LayoutType {
    case type1, type2, type3, type4
}
