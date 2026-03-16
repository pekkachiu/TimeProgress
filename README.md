# TimeProgress

A minimal iOS/macOS SwiftUI app that visualizes how much of the current year, month, week, or day has passed — using a dot-grid progress display.

## Screenshots

<!-- Add screenshots here -->

## Features

- View time progress for **year / month / week / day**
- Dot-grid visualization where each dot represents a unit of time
- WidgetKit extension with **small, medium, and large** widget sizes
- Supports **iOS** and **macOS**
- Light/dark mode adaptive

## Requirements

- Xcode 16+
- iOS 18+ / macOS 15+

## Getting Started

1. Clone the repo
   ```bash
   git clone https://github.com/pekkachiu/TimeProgress.git
   ```
2. Open `TimeProgress.xcodeproj` in Xcode
3. Select your Development Team in **Signing & Capabilities**
4. Build and run

## Project Structure

```
TimeProgress/
├── TimeProgress/          # Main app
│   ├── ContentView.swift
│   ├── ProgressCardView.swift
│   ├── DotsGrid.swift
│   ├── StatBlock.swift
│   ├── TimeScope.swift            # Shared with widget
│   ├── TimeProgressCalculator.swift  # Shared with widget
│   └── TimeProgressValue.swift    # Shared with widget
└── widget new/            # WidgetKit extension
    ├── widget_new.swift
    ├── widget_newBundle.swift
    └── AppIntent.swift
```

## License

MIT
