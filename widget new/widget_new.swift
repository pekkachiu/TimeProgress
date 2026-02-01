//
//  widget_new.swift (帶 Preview 測試版)
//  widget new
//
//  Created by PekkaChiu on 2026/1/31.
//

import Foundation
import WidgetKit
import SwiftUI

private enum WidgetPalette {
    static let primary = Color(.sRGB, red: 200.0 / 255.0, green: 202.0 / 255.0, blue: 197.0 / 255.0, opacity: 1)
    static let secondary = Color(.sRGB, red: 110.0 / 255.0, green: 118.0 / 255.0, blue: 108.0 / 255.0, opacity: 1)
    static let background = Color(.sRGB, red: 47.0 / 255.0, green: 73.0 / 255.0, blue: 65.0 / 255.0, opacity: 1)
    static let inactiveDot = background.opacity(0.7)
}

private struct GridLayout {
    let columns: Int
    let rows: Int
    let dotSize: CGFloat
    let spacing: CGFloat

    static func fitted(total: Int, in size: CGSize, spacingRatio: CGFloat) -> GridLayout {
        let safeTotal = max(total, 1)
        let ratio = max(spacingRatio, 0)
        let safeWidth = max(size.width, 1)
        let safeHeight = max(size.height, 1)

        var bestColumns = 1
        var bestRows = safeTotal
        var bestDotSize: CGFloat = 0
        var bestUnused: CGFloat = .greatestFiniteMagnitude
        let maxColumns = min(safeTotal, 120)

        for columns in 1...maxColumns {
            let rows = Int(ceil(Double(safeTotal) / Double(columns)))
            let widthUnits = CGFloat(columns) + CGFloat(columns - 1) * ratio
            let heightUnits = CGFloat(rows) + CGFloat(rows - 1) * ratio
            let dotSizeWidth = safeWidth / max(widthUnits, 1)
            let dotSizeHeight = safeHeight / max(heightUnits, 1)
            let dotSize = min(dotSizeWidth, dotSizeHeight)
            if dotSize <= 0 { continue }

            let usedWidth = dotSize * widthUnits
            let usedHeight = dotSize * heightUnits
            let unused = pow(safeWidth - usedWidth, 2) + pow(safeHeight - usedHeight, 2)

            if unused < bestUnused - 0.001 || (abs(unused - bestUnused) <= 0.001 && dotSize > bestDotSize) {
                bestDotSize = dotSize
                bestColumns = columns
                bestRows = rows
                bestUnused = unused
            }
        }

        let widthUnits = CGFloat(bestColumns) + CGFloat(bestColumns - 1) * ratio
        let heightUnits = CGFloat(bestRows) + CGFloat(bestRows - 1) * ratio
        let dotSize = max(1, min(safeWidth / max(widthUnits, 1), safeHeight / max(heightUnits, 1)))
        let spacing = dotSize * ratio

        return GridLayout(columns: bestColumns, rows: bestRows, dotSize: dotSize, spacing: spacing)
    }
}

private struct FittedDotsGrid: View {
    let progress: Double
    let config: GridConfig
    let alignment: HorizontalAlignment
    let filledColor: Color
    let emptyColor: Color

    var body: some View {
        GeometryReader { proxy in
            let ratio = config.spacing / max(config.dotSize, 1)
            let layout = GridLayout.fitted(
                total: config.count,
                in: proxy.size,
                spacingRatio: ratio
            )
            let displayTotal = layout.columns * layout.rows

            DotsGrid(
                progress: progress,
                total: displayTotal,
                dotSize: layout.dotSize,
                spacing: layout.spacing,
                alignment: alignment,
                filledColor: filledColor,
                emptyColor: emptyColor,
                columnsCount: layout.columns,
                progressTotal: displayTotal
            )
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment == .center ? .center : .topLeading)
        }
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(macOSApplicationExtension 14.0, iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), scope: .year)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), scope: configuration.scope)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let now = Date()
        let entry = SimpleEntry(date: now, scope: configuration.scope)
        let nextUpdate = nextUpdateDate(for: configuration.scope, now: now)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    private func nextUpdateDate(for scope: TimeScope, now: Date) -> Date {
        switch scope {
        case .day:
            return nextIntervalUpdateDate(now: now, minutes: 30)
        case .week, .month, .year:
            return nextDailyUpdateDate(now: now)
        }
    }

    private func nextDailyUpdateDate(now: Date) -> Date {
        let calendar = TimeProgressCalculator.cal
        let startOfDay = calendar.startOfDay(for: now)
        return calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now.addingTimeInterval(3600)
    }

    private func nextIntervalUpdateDate(now: Date, minutes: Int) -> Date {
        let calendar = TimeProgressCalculator.cal
        let currentMinute = calendar.component(.minute, from: now)
        let remainder = currentMinute % minutes
        let minutesToAdd = minutes - remainder
        let next = calendar.date(byAdding: .minute, value: minutesToAdd, to: now) ?? now.addingTimeInterval(Double(minutes * 60))
        return calendar.date(bySetting: .second, value: 0, of: next) ?? next
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let scope: TimeScope
}

struct widget_newEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let value = TimeProgressCalculator.value(for: entry.scope, now: entry.date)
        let config = entry.scope.layoutConfig(for: family, now: entry.date)

        Group {
            switch family {
            case .systemSmall:
                smallView(value: value, config: config)
            case .systemLarge:
                rawLargeView(value: value, config: config)
            default:
                rawMediumView(value: value, config: config)
            }
        }
    }

    private func smallView(value: TimeProgressValue, config: GridConfig) -> some View {
        let contentPadding: CGFloat = 10

        return VStack(alignment: .leading, spacing: 10) {
            Text(value.title)
                .font(.headline)
                .bold()

            FittedDotsGrid(
                progress: value.progress,
                config: config,
                alignment: .leading,
                filledColor: WidgetPalette.primary,
                emptyColor: WidgetPalette.inactiveDot
            )
            .layoutPriority(1)
            
            Spacer(minLength: 0)

            WidgetStatBlock(value: value.left.0, label: value.left.1, emphasize: true)
        }
        .foregroundStyle(WidgetPalette.primary)
        .padding(contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func rawMediumView(value: TimeProgressValue, config: GridConfig) -> some View {
        let contentPadding: CGFloat = 12

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(value.title)
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text(value.passedLabel)
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.secondary)
            }
            
            FittedDotsGrid(
                progress: value.progress,
                config: config,
                alignment: .leading,
                filledColor: WidgetPalette.primary,
                emptyColor: WidgetPalette.inactiveDot
            )
            .layoutPriority(1)
            
            Spacer(minLength: 0)

            HStack {
                WidgetStatBlock(value: value.left.0, label: value.left.1, emphasize: true)
                Spacer()
                WidgetStatBlock(value: value.middle.0, label: value.middle.1)
                Spacer()
                WidgetStatBlock(value: value.right.0, label: value.right.1)
            }
        }
        .foregroundStyle(WidgetPalette.primary)
        .padding(contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func rawLargeView(value: TimeProgressValue, config: GridConfig) -> some View {
        let contentPadding: CGFloat = 14

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(value.title)
                    .font(.title3)
                    .bold()
                Spacer()
                Text(value.passedLabel)
                    .font(.body)
                    .foregroundStyle(WidgetPalette.secondary)
            }

            FittedDotsGrid(
                progress: value.progress,
                config: config,
                alignment: .center,
                filledColor: WidgetPalette.primary,
                emptyColor: WidgetPalette.inactiveDot
            )
            .layoutPriority(1)
            
            Spacer(minLength: 0)

            HStack {
                WidgetStatBlock(value: value.left.0, label: value.left.1, emphasize: true)
                Spacer()
                WidgetStatBlock(value: value.middle.0, label: value.middle.1)
                Spacer()
                WidgetStatBlock(value: value.right.0, label: value.right.1)
            }
        }
        .foregroundStyle(WidgetPalette.primary)
        .padding(contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct WidgetStatBlock: View {
    let value: String
    let label: String
    var emphasize: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .bold(emphasize)
                .foregroundStyle(WidgetPalette.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(WidgetPalette.secondary)
        }
    }
}

struct widget_new: Widget {
    static let kind: String = "widget_new"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: widget_new.kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            if #available(macOSApplicationExtension 14.0, iOSApplicationExtension 17.0, *) {
                widget_newEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetPalette.background
                    }
            } else {
                widget_newEntryView(entry: entry)
                    .padding()
                    .background(WidgetPalette.background)
            }
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

// ✅ 加上這個就可以在 Xcode 裡即時預覽!
#Preview(as: .systemMedium) {
    widget_new()
} timeline: {
    SimpleEntry(date: .now, scope: .week)
}
