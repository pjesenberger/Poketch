//
//  AppIntent.swift
//  PoketchWidget
//
//  Created by Pascal Jesenberger on 18/08/2026.
//

import WidgetKit
import AppIntents
import SwiftUI

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Poketch" }
    static var description: IntentDescription { "Poketch Widget" }
}

enum ColorShade {
    case light
    case normal
    case dark
    case black
}

enum AppTheme: String {
    case blue, gray, green, orange, purple, red, turquoise, yellow

    private var name: String {
        rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }

    func color(_ shade: ColorShade, glowing: Bool = false) -> Color {
        let glow = glowing ? "Glowing" : ""
        let shadeName: String
        switch shade {
        case .light: shadeName = "Light"
        case .normal: shadeName = ""
        case .dark: shadeName = "Dark"
        case .black: shadeName = "Black"
        }
        return Color("app\(glow)\(shadeName)\(name)")
    }
}

nonisolated enum SharedStore {
    private static let suiteName = "group.me.jesenberger.pascal.Poketch"
    private static let glowKey = "isGlowing"
    private static let themeKey = "theme"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static var isGlowing: Bool {
        defaults?.bool(forKey: glowKey) ?? false
    }

    static func toggleGlow() {
        defaults?.set(!isGlowing, forKey: glowKey)
    }

    static var theme: AppTheme {
        AppTheme(rawValue: defaults?.string(forKey: themeKey) ?? "") ?? .green
    }

    static func setTheme(_ theme: AppTheme) {
        defaults?.set(theme.rawValue, forKey: themeKey)
    }
}

struct ToggleGlowIntent: AppIntent {
    static var title: LocalizedStringResource { "Toggle Glow" }

    func perform() async throws -> some IntentResult {
        SharedStore.toggleGlow()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
