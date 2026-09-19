//
//  MainView.swift
//  Poketch
//
//  Created by Pascal Jesenberger on 17/08/2026.
//

import SwiftUI
import WidgetKit

struct MainView: View {
    @State private var theme: AppTheme = SharedStore.theme
    @State private var haptic = UIImpactFeedbackGenerator(style: .light)
    @State private var showWelcome = false
    
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let themes: [AppTheme] = [.green, .yellow, .orange, .red, .purple, .blue, .turquoise, .gray]
    
    private let tickWidth: CGFloat = 9
    private let tickSpacing: CGFloat = 22
    private let trackWidth: CGFloat = 290
    
    private var scale: CGFloat {
        horizontalSizeClass == .regular ? 1.2 : 1
    }
    
    private var tickCount: Int { themes.count }
    
    private var stepDistance: CGFloat { tickWidth + tickSpacing }
    
    private var ticksWidth: CGFloat {
        CGFloat(tickCount) * tickWidth + CGFloat(tickCount - 1) * tickSpacing
    }
    
    private var stepIndex: Int {
        themes.firstIndex(of: theme) ?? 0
    }
    
    private func offset(for index: Int) -> CGFloat {
        let firstCenter = -ticksWidth / 2 + tickWidth / 2
        return firstCenter + CGFloat(index) * stepDistance
    }
    
    private func nearestIndex(atX x: CGFloat) -> Int {
        let fromCenter = x - trackWidth / 2
        let firstCenter = offset(for: 0)
        let nearest = (fromCenter - firstCenter) / stepDistance
        return min(max(Int(nearest.rounded()), 0), tickCount - 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.color(.light)
                
                if #available(anyAppleOS 27.1, *) {
                    GeometryReader { proxy in
                        if proxy.reservedRegions(kind: .division).contains(where: { $0.isActive }) {
                            ArrangementView {
                                kecleon
                                    .scaleEffect(scale)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } secondary: {
                                themePicker
                                    .scaleEffect(scale)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .arrangementViewStyle(.split)
                        } else {
                            stack
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                } else {
                    stack
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            guard !hasSeenWelcome else { return }
            hasSeenWelcome = true
            showWelcome = true
        }
        .alert("Welcome to Pokétch!", isPresented: $showWelcome) {
            Button("OK") {}
                .keyboardShortcut(.defaultAction)
        } message: {
            Text("Tap Pikachu on the widget to make it glow and try different color variations!")
        }
    }
    
    private var stack: some View {
        VStack(spacing: 24) {
            kecleon
            
            themePicker
        }
        .scaleEffect(scale)
    }
    
    private var kecleon: some View {
        Image("Kecleon")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 246)
            .foregroundColor(theme.color(.normal))
    }
    
    private var themePicker: some View {
        Rectangle()
            .stroke(lineWidth: 10)
            .foregroundColor(theme.color(.dark))
            .frame(width: trackWidth, height: 70)
            .overlay(
                Rectangle()
                    .foregroundColor(theme.color(.dark))
                    .frame(width: 260, height: 9)
                    .overlay(
                        HStack(spacing: tickSpacing) {
                            ForEach(0..<tickCount, id: \.self) { _ in
                                Rectangle()
                                    .foregroundColor(theme.color(.dark))
                                    .frame(width: tickWidth, height: 30)
                            }
                        }
                    )
            )
            .overlay(cube)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        select(themes[nearestIndex(atX: value.location.x)])
                    }
            )
    }
    
    private var cube: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.color(.light))
                .frame(width: 60, height: 48)
            
            Rectangle()
                .fill(theme.color(.dark))
                .frame(width: 60, height: 5)
            
            Rectangle()
                .fill(theme.color(.normal))
                .frame(width: 60, height: 12)
        }
        .overlay(
            Rectangle()
                .stroke(theme.color(.black), lineWidth: 5)
        )
        .offset(x: offset(for: stepIndex))
    }
    
    private func select(_ item: AppTheme) {
        guard item != theme else { return }
        haptic.impactOccurred()
        haptic.prepare()
        theme = item
        SharedStore.setTheme(item)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    MainView()
}
