//
//  TimeScope.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//

import Foundation
import CoreGraphics
#if canImport(WidgetKit)
import WidgetKit
#endif

struct GridConfig {
    let dotSize: CGFloat
    let spacing: CGFloat
    let count: Int
}

enum TimeScope: String, CaseIterable, Identifiable {
    case year = "年"
    case month = "月"
    case week = "週"
    case day = "日"

    var id: String { rawValue }
}

#if canImport(WidgetKit)
extension TimeScope {
    func layoutConfig(for family: WidgetFamily, now: Date = .now) -> GridConfig {
        switch self {
        case .year:
            switch family {
            case .systemSmall:
                return GridConfig(dotSize: 5, spacing: 3, count: 100)
            case .systemLarge:
                return GridConfig(dotSize: 8, spacing: 6, count: 365)
            default:
                return GridConfig(dotSize: 5, spacing: 4, count: 365)
            }
        case .month:
            let count = TimeProgressCalculator.cal.range(of: .day, in: .month, for: now)?.count ?? 30
            switch family {
            case .systemSmall:
                return GridConfig(dotSize: 8, spacing: 6, count: count)
            default:
                return GridConfig(dotSize: 12, spacing: 8, count: count)
            }
        case .week:
            switch family {
            case .systemSmall:
                return GridConfig(dotSize: 14, spacing: 8, count: 7)
            default:
                return GridConfig(dotSize: 20, spacing: 12, count: 7)
            }
        case .day:
            switch family {
            case .systemSmall:
                return GridConfig(dotSize: 8, spacing: 6, count: 24)
            default:
                return GridConfig(dotSize: 12, spacing: 8, count: 24)
            }
        }
    }
}
#endif
