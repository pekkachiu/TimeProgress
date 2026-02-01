//
//  ProgressCardView.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//

import SwiftUI

struct ProgressCardView: View {
    let value: TimeProgressValue
    let scope: TimeScope

    let contentPadding: CGFloat
    let gridAlignment: HorizontalAlignment

    init(
        value: TimeProgressValue,
        scope: TimeScope,
        contentPadding: CGFloat = 0,
        gridAlignment: HorizontalAlignment = .leading
    ) {
        self.value = value
        self.scope = scope
        self.contentPadding = contentPadding
        self.gridAlignment = gridAlignment
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(value.title)
                    .font(.headline)
                    .bold()

                Spacer()

                Text(value.passedLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            DotsGrid(
                progress: value.progress,
                total: TimeProgressCalculator.dotsCount(for: scope),
                alignment: gridAlignment
            )

            HStack {
                StatBlock(value: value.left.0, label: value.left.1, emphasize: true)
                Spacer()
                StatBlock(value: value.middle.0, label: value.middle.1)
                Spacer()
                StatBlock(value: value.right.0, label: value.right.1)
            }
        }
        .padding(contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
