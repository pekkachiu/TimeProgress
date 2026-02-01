//
//  DotsGrid.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//

import SwiftUI

struct DotsGrid: View {
    let progress: Double
    let total: Int
    let progressTotal: Int
    let dotSize: CGFloat
    let spacing: CGFloat
    let filledColor: Color
    let emptyColor: Color
    let columnsCount: Int?
    
    // 新增：讓外部決定要靠左還是置中 (預設靠左，保持 App 原樣)
    let alignment: HorizontalAlignment

    init(
        progress: Double,
        total: Int,
        dotSize: CGFloat = 6,
        spacing: CGFloat = 6,
        alignment: HorizontalAlignment = .leading,
        filledColor: Color = .primary,
        emptyColor: Color = Color.primary.opacity(0.2),
        columnsCount: Int? = nil,
        progressTotal: Int? = nil
    ) {
        self.progress = progress
        self.total = total
        self.progressTotal = progressTotal ?? total
        self.dotSize = dotSize
        self.spacing = spacing
        self.alignment = alignment
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.columnsCount = columnsCount
    }

    init(
        progress: Double,
        config: GridConfig,
        alignment: HorizontalAlignment = .leading,
        filledColor: Color = .primary,
        emptyColor: Color = Color.primary.opacity(0.2),
        columnsCount: Int? = nil,
        progressTotal: Int? = nil
    ) {
        self.progress = progress
        self.total = config.count
        self.progressTotal = progressTotal ?? config.count
        self.dotSize = config.dotSize
        self.spacing = config.spacing
        self.alignment = alignment
        self.filledColor = filledColor
        self.emptyColor = emptyColor
        self.columnsCount = columnsCount
    }

    private var filled: Int {
        max(0, min(progressTotal, Int(round(progress * Double(progressTotal)))))
    }

    private var columns: [GridItem] {
        if let columnsCount, columnsCount > 0 {
            return Array(repeating: GridItem(.fixed(dotSize), spacing: spacing), count: columnsCount)
        }
        return [GridItem(.adaptive(minimum: dotSize, maximum: dotSize), spacing: spacing)]
    }

    var body: some View {
        LazyVGrid(columns: columns, alignment: alignment, spacing: spacing) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < filled ? filledColor : emptyColor)
                    .frame(width: dotSize, height: dotSize)
            }
        }
    }
}
