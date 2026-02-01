//
//  StatBlock.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//

import SwiftUI

struct StatBlock: View {
    let value: String
    let label: String
    var emphasize: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .bold(emphasize)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
