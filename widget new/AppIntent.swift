//
//  AppIntent.swift
//  widget new
//
//  Created by PekkaChiu on 2026/1/31.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "時間進度" }
    static var description: IntentDescription { "選擇要顯示的時間範圍。" }

    @Parameter(title: "範圍", default: .year)
    var scope: TimeScope
}

// 透過擴展讓 TimeScope 符合 AppEnum
extension TimeScope: AppEnum {
    
    // 加上 nonisolated 確保這兩個靜態屬性能在任何地方被安全讀取，不被限制在主執行緒
    public nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "時間範圍")
    }

    public nonisolated static var caseDisplayRepresentations: [TimeScope: DisplayRepresentation] {
        [
            .year: DisplayRepresentation(title: "年"),
            .month: DisplayRepresentation(title: "月"),
            .week: DisplayRepresentation(title: "週"),
            .day: DisplayRepresentation(title: "日")
        ]
    }
}
