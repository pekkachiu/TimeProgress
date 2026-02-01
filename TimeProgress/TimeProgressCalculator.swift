//
//  TimeProgressCalculator.swift
//  TimeProgress
//
//  Created by PekkaChiu on 2026/1/26.
//

import Foundation

enum TimeProgressCalculator {

    // 週一為一週開始：firstWeekday = 2
    static var cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "zh_Hant_TW")
        c.firstWeekday = 2 // Monday
        c.minimumDaysInFirstWeek = 4
        return c
    }()

    static func dotsCount(for scope: TimeScope) -> Int {
        switch scope {
        case .year:  return 364  // 視覺用：做成 26x14 的密度比較漂亮
        case .month: return 140  // 視覺用
        case .week:  return 70   // 視覺用
        case .day:   return 96   // 15 分鐘一格（24*4）
        }
    }

    static func value(for scope: TimeScope, now: Date) -> TimeProgressValue {
        switch scope {
        case .year:
            return yearValue(now)
        case .month:
            return monthValue(now)
        case .week:
            return weekValue(now)
        case .day:
            return dayValue(now)
        }
    }

    // MARK: - Year

    static func yearValue(_ now: Date) -> TimeProgressValue {
        let year = cal.component(.year, from: now)
        let start = cal.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = cal.date(from: DateComponents(year: year + 1, month: 1, day: 1))!

        let passedDays = cal.dateComponents([.day], from: start, to: now).day! + 1
        let totalDays = cal.dateComponents([.day], from: start, to: end).day!
        let remainingDays = max(0, totalDays - passedDays)
        let remainingWeeks = Int(ceil(Double(remainingDays) / 7.0))
        let progress = clamp(Double(passedDays) / Double(totalDays))

        return TimeProgressValue(
            title: "\(year) 年度進度",
            passedLabel: "已過 \(passedDays) 天",
            progress: progress,
            left: (percent(progress), "進度"),
            middle: ("\(remainingDays)", "天剩餘"),
            right: ("\(remainingWeeks)", "週剩餘")
        )
    }

    // MARK: - Month

    static func monthValue(_ now: Date) -> TimeProgressValue {
        let year = cal.component(.year, from: now)
        let month = cal.component(.month, from: now)

        let start = cal.date(from: DateComponents(year: year, month: month, day: 1))!
        let end = cal.date(byAdding: DateComponents(month: 1), to: start)!

        let passedDays = cal.dateComponents([.day], from: start, to: now).day! + 1
        let totalDays = cal.dateComponents([.day], from: start, to: end).day!
        let remainingDays = max(0, totalDays - passedDays)
        let progress = clamp(Double(passedDays) / Double(totalDays))

        return TimeProgressValue(
            title: "\(month) 月進度",
            passedLabel: "已過 \(passedDays) 天",
            progress: progress,
            left: (percent(progress), "進度"),
            middle: ("\(remainingDays)", "天剩餘"),
            right: ("\(totalDays)", "本月天數")
        )
    }

    // MARK: - Week (Monday-based)

    static func weekValue(_ now: Date) -> TimeProgressValue {
        let start = cal.dateInterval(of: .weekOfYear, for: now)!.start
        let end = cal.date(byAdding: .day, value: 7, to: start)!

        // 以天為單位顯示「已過幾天」；週一算第1天
        let passedDays = cal.dateComponents([.day], from: start, to: now).day! + 1
        let totalDays = 7
        let remainingDays = max(0, totalDays - passedDays)
        let progress = clamp(Double(passedDays) / Double(totalDays))

        // 顯示週期範圍（可選）
        return TimeProgressValue(
            title: "本週進度",
            passedLabel: "已過 \(passedDays) 天",
            progress: progress,
            left: (percent(progress), "進度"),
            middle: ("\(remainingDays)", "天剩餘"),
            right: ("7", "本週天數")
        )
    }

    // MARK: - Day

    static func dayValue(_ now: Date) -> TimeProgressValue {
        let start = cal.startOfDay(for: now)
        let end = cal.date(byAdding: .day, value: 1, to: start)!

        let secondsPassed = now.timeIntervalSince(start)
        let secondsTotal = end.timeIntervalSince(start)
        let progress = clamp(secondsPassed / secondsTotal)

        let hoursPassed = Int(secondsPassed / 3600.0)
        let minutesLeft = max(0, Int(ceil((secondsTotal - secondsPassed) / 60.0)))
        let hoursLeft = minutesLeft / 60

        return TimeProgressValue(
            title: "今日進度",
            passedLabel: "已過 \(hoursPassed) 小時",
            progress: progress,
            left: (percent(progress), "進度"),
            middle: ("\(minutesLeft)", "分鐘剩餘"),
            right: ("\(hoursLeft)", "小時剩餘")
        )
    }

    // MARK: - Helpers

    static func clamp(_ x: Double) -> Double {
        min(1, max(0, x))
    }

    static func percent(_ p: Double) -> String {
        String(format: "%.2f%%", p * 100.0)
    }
}
