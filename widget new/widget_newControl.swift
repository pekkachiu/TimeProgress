//
//  widget_newControl.swift
//  widget new
//
//  Created by PekkaChiu on 2026/1/31.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 18.0, macOSApplicationExtension 15.0, *)
struct widget_newControl: ControlWidget {
    static let kind: String = "com.example.TimeProgress.widget_new.control"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "更新時間進度",
                isOn: value.isRefreshing,
                action: RefreshTimeProgressIntent()
            ) { isRefreshing in
                Label(isRefreshing ? "更新中" : "重新整理", systemImage: "arrow.clockwise")
            }
        }
        .displayName("時間進度")
        .description("點一下即可重新整理桌面小工具。")
    }
}

@available(iOSApplicationExtension 18.0, macOSApplicationExtension 15.0, *)
extension widget_newControl {
    struct Value {
        var isRefreshing: Bool
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: RefreshConfiguration) -> Value {
            widget_newControl.Value(isRefreshing: false)
        }

        func currentValue(configuration: RefreshConfiguration) async throws -> Value {
            widget_newControl.Value(isRefreshing: false)
        }
    }
}

@available(iOSApplicationExtension 18.0, macOSApplicationExtension 15.0, *)
struct RefreshConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "時間進度"
}

@available(iOSApplicationExtension 18.0, macOSApplicationExtension 15.0, *)
struct RefreshTimeProgressIntent: SetValueIntent {
    static let title: LocalizedStringResource = "刷新時間進度"

    @Parameter(title: "刷新")
    var value: Bool

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: widget_new.kind)
        return .result()
    }
}
