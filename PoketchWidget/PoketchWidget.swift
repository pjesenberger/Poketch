//
//  PoketchWidget.swift
//  PoketchWidget
//
//  Created by Pascal Jesenberger on 18/08/2026.
//

import WidgetKit
import SwiftUI
import AppIntents

enum PoketchFont {
    static let name = "PoketchDigits"
    static let size: CGFloat = 98
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isGlowing: false, theme: .green)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), isGlowing: SharedStore.isGlowing, theme: SharedStore.theme)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let isGlowing = SharedStore.isGlowing
        let theme = SharedStore.theme
        let calendar = Calendar.current
        let now = Date()
        
        let currentMinute = calendar.date(
            from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        ) ?? now
        
        let entries = (0..<60).compactMap { offset in
            calendar.date(byAdding: .minute, value: offset, to: currentMinute).map {
                SimpleEntry(date: $0, isGlowing: isGlowing, theme: theme)
            }
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isGlowing: Bool
    let theme: AppTheme
}

enum PikachuSprite {
    static let canvasWidth: CGFloat = 164
    static let body = CGRect(x: 8, y: 0, width: 60, height: 36)
}

struct PoketchWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    
    private var fontSize: CGFloat {
        family == .systemLarge ? PoketchFont.size * 2.2 : PoketchFont.size
    }
    
    private var normalColor: Color {
        entry.theme.color(.normal, glowing: entry.isGlowing)
    }
    
    private var darkColor: Color {
        entry.theme.color(.dark, glowing: entry.isGlowing)
    }
    
    private var glowButton: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / PikachuSprite.canvasWidth
            
            Button(intent: ToggleGlowIntent()) {
                Color.clear.contentShape(.rect)
            }
            .buttonStyle(.plain)
            .frame(width: PikachuSprite.body.width * scale,
                   height: PikachuSprite.body.height * scale)
            .position(x: PikachuSprite.body.midX * scale,
                      y: PikachuSprite.body.midY * scale)
        }
    }
    
    var body: some View {
        ZStack {
            Image(.topRectangle)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(normalColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            Text(
                TimeDataSource<Duration>.durationOffset(to: Calendar.current.startOfDay(for: entry.date)),
                format: .time(pattern: .hourMinute(padHourToLength: 2, roundSeconds: .down))
                    .locale(Locale(identifier: "fr_FR"))
            )
            .font(.custom(PoketchFont.name, size: fontSize))
            .foregroundColor(darkColor)
            .lineLimit(1)
            .contentTransition(.identity)
            .transaction { $0.animation = nil }
            .multilineTextAlignment(.center)
            
            ZStack {
                Image(.pikachuDark)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(darkColor)
                
                Image(.pikachuLight)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(normalColor)
            }
            .overlay {
                glowButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct PoketchWidget: Widget {
    let kind: String = "PoketchWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PoketchWidgetEntryView(entry: entry)
                .containerBackground(entry.theme.color(.light, glowing: entry.isGlowing), for: .widget)
        }
        .containerBackgroundRemovable(false)
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

#Preview(as: .systemLarge) {
    PoketchWidget()
} timeline: {
    SimpleEntry(date: .now, isGlowing: false, theme: .green)
}
