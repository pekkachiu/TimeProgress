//
//  ContentView.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//
import SwiftUI

struct ContentView: View {
    @State private var scope: TimeScope = .year

    var body: some View {
        let v = TimeProgressCalculator.value(for: scope, now: Date())

        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {

                // 四種模式選擇
                Picker("", selection: $scope) {
                    ForEach(TimeScope.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // 卡片本體
                ProgressCardView(value: v, scope: scope, contentPadding: 0)

                Spacer()
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    ContentView()
}
