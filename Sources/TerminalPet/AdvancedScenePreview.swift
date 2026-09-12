import Foundation
import SwiftUI

struct AdvancedScenePreview: View {
    @EnvironmentObject private var model: AppModel
    @State private var previewOpener = "The machine spirit accepts your offering."

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Circle().fill(Color.red.opacity(0.86)).frame(width: 10, height: 10)
                Circle().fill(Color.yellow.opacity(0.86)).frame(width: 10, height: 10)
                Circle().fill(Color.green.opacity(0.86)).frame(width: 10, height: 10)
                Spacer()
                Text(windowTitle)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                    .lineLimit(1)
                Spacer()
                Button(action: reroll) {
                    Image(systemName: "dice.fill")
                        .foregroundColor(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(Color.white.opacity(0.035))

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 7) {
                        Image(systemName: model.customization.introEffect.symbol)
                        Text(model.customization.introEffect.rawValue.uppercased())
                        Text("·")
                        Text(model.customization.frequency.rawValue.uppercased())
                    }
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(model.customization.metadataTint.color.opacity(0.72))

                    artView

                    if model.customization.dividerStyle != .none {
                        Text(model.customization.dividerStyle.glyphs)
                            .foregroundColor(model.customization.secondaryTint.color.opacity(0.58))
                    }

                    if model.showPetName {
                        (Text(model.selectedPet.name).bold().foregroundColor(model.tint.color)
                         + Text("  " + expandedOpener).foregroundColor(model.customization.openerTint.color))
                    } else {
                        Text(expandedOpener).foregroundColor(model.customization.openerTint.color)
                    }

                    if !metadata.isEmpty {
                        Text(metadata.joined(separator: "  ·  "))
                            .foregroundColor(model.customization.metadataTint.color.opacity(0.82))
                    }

                    PromptPreview(settings: model.customization.prompt, showCursor: true)
                        .padding(.top, 5)
                }
                .font(.system(size: 11.5, design: .monospaced))
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }

            HStack {
                Circle().fill(AppTheme.accent).frame(width: 6, height: 6)
                Text("LIVE COMPOSITION")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Text("\(model.rotationPets.count) pet\(model.rotationPets.count == 1 ? "" : "s") · \(model.enabledOpeners.count) lines")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
            }
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(Color.white.opacity(0.025))
        }
        .background(AppTheme.terminal)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.11)))
        .shadow(color: .black.opacity(0.28), radius: 24, y: 14)
        .onAppear(perform: reroll)
    }

    @ViewBuilder
    private var artView: some View {
        switch model.customization.petColorMode {
        case .solid:
            Text(model.selectedPet.art)
                .foregroundColor(model.tint.color)
                .shadow(color: model.tint.color.opacity(0.22), radius: 8)
        case .duotone:
            Text(model.selectedPet.art)
                .foregroundStyle(
                    LinearGradient(
                        colors: [model.tint.color, model.customization.secondaryTint.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .rainbow:
            Text(model.selectedPet.art)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private var expandedOpener: String {
        previewOpener
            .replacingOccurrences(of: "{user}", with: NSUserName())
            .replacingOccurrences(of: "{host}", with: Host.current().localizedName ?? "this-mac")
            .replacingOccurrences(of: "{cwd}", with: "~/Coding/TerminalPet")
            .replacingOccurrences(of: "{pet}", with: model.selectedPet.name)
    }

    private var windowTitle: String {
        guard model.customization.setWindowTitle else { return "zsh — 92×28" }
        return model.customization.windowTitle
            .replacingOccurrences(of: "{user}", with: NSUserName())
            .replacingOccurrences(of: "{host}", with: "this-mac")
            .replacingOccurrences(of: "{cwd}", with: "~/Coding/TerminalPet")
            .replacingOccurrences(of: "{pet}", with: model.selectedPet.name)
    }

    private var metadata: [String] {
        let settings = model.customization
        var items: [String] = []
        if settings.showClock { items.append("09:41") }
        if settings.showDate { items.append("SAT SEP 12") }
        if settings.showUserHost { items.append("\(NSUserName())@this-mac") }
        if settings.showCWD { items.append("~/Coding/TerminalPet") }
        if settings.showOS { items.append("macOS 26.0") }
        if settings.showArchitecture { items.append("arm64") }
        if settings.showShell { items.append("zsh") }
        if settings.showBattery { items.append("87% ⚡") }
        if settings.showUptime { items.append("up 4h 12m") }
        if settings.showGitBranch { items.append("git:main") }
        return items
    }

    private func reroll() {
        previewOpener = model.randomPreviewOpener()?.text ?? ""
    }
}
