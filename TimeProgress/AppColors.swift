//
//  AppColors.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum AppColors {
    static var background: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return .black
        #endif
    }
}

