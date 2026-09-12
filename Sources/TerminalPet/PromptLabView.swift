import SwiftUI

struct PromptLabView: View {
    @EnvironmentObject private var model: AppModel
    @State private var demoFailure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .bottom) {
                SectionTitle(
                    eyebrow: "04 / Prompt",
                    title: "Rebuild the command line",
                    subtitle: "An optional dynamic prompt for zsh and Bash—with git, status, time, and attitude."
                )
                Spacer()
                Toggle("CUSTOM PROMPT", isOn: promptBinding(\.enabled))
                    .toggleStyle(.switch)
                    .tint(AppTheme.accent)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
            }

            HStack(alignment: .top, spacing: 18) {
                ScrollView {
                    VStack(spacing: 14) {
                        styleCard
                        segmentsCard
                        promptColorCard
                        compatibilityCard
                    }
                    .padding(1)
                }
                .frame(minWidth: 430, idealWidth: 490, maxWidth: 540)
                .disabled(!model.customization.prompt.enabled)
                .opacity(model.customization.prompt.enabled ? 1 : 0.50)

                previewCard
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 42)
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
        .background(AppTheme.background)
    }

    private var styleCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            CardHeading(symbol: "rectangle.3.group", title: "Prompt shape", detail: "All styles use plain Unicode—no Nerd Font ransom payment")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(PromptStyle.allCases) { style in
                    let selected = model.customization.prompt.style == style
                    Button { setPromptStyle(style) } label: {
                        HStack(spacing: 8) {
                            Image(systemName: style.symbol)
                            Text(style.rawValue)
                            Spacer()
                            if selected { Image(systemName: "checkmark.circle.fill") }
                        }
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(selected ? model.customization.prompt.primaryTint.color : AppTheme.secondaryText)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(RoundedRectangle(cornerRadius: 8).fill(selected ? model.customization.prompt.primaryTint.color.opacity(0.09) : Color.black.opacity(0.12)))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(selected ? model.customization.prompt.primaryTint.color.opacity(0.34) : AppTheme.border))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text("PROMPT SYMBOL")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                TextField("❯", text: promptBinding(\.symbol))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 90)
                Text("Try  ❯  ◆  λ  →  ⚡  $  #")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
            }
        }
        .terminalCard(padding: 16)
    }

    private var segmentsCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            CardHeading(symbol: "square.split.2x1", title: "Segments", detail: "Each one updates before every prompt")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                PromptOption(title: "Time", detail: "09:41", isOn: promptBinding(\.showTime))
                PromptOption(title: "User + host", detail: "bragi@mac", isOn: promptBinding(\.showUserHost))
                PromptOption(title: "Directory", detail: "~/Coding", isOn: promptBinding(\.showCWD))
                PromptOption(title: "Git branch", detail: "git:main", isOn: promptBinding(\.showGitBranch))
                PromptOption(title: "Exit status", detail: "✕ 127", isOn: promptBinding(\.showExitStatus))
                PromptOption(title: "Error reactions", detail: "pet commentary", isOn: promptBinding(\.errorReactions))
            }
        }
        .terminalCard(padding: 16)
    }

    private var promptColorCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            CardHeading(symbol: "paintbrush.pointed.fill", title: "Prompt colors", detail: "Primary structure and secondary live data")
            TintChooser(title: "PRIMARY", selection: promptBinding(\.primaryTint))
            TintChooser(title: "SECONDARY", selection: promptBinding(\.secondaryTint))
        }
        .terminalCard(padding: 16)
    }

    private var compatibilityCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow.opacity(0.85))
            VStack(alignment: .leading, spacing: 3) {
                Text("Prompt ownership is exclusive")
                    .font(.system(size: 11, weight: .semibold))
                Text("Enabling this intentionally replaces the visible prompt from Oh My Zsh, Starship, Powerlevel10k, or a hand-written PS1. Disable it to leave those tools completely alone.")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .terminalCard(padding: 14)
    }

    private var previewCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("PROMPT SIMULATOR")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Picker("", selection: $demoFailure) {
                    Text("Success").tag(false)
                    Text("Failed command").tag(true)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 190)
            }
            .padding(14)

            Rectangle().fill(AppTheme.border).frame(height: 1)

            VStack(alignment: .leading, spacing: 16) {
                Text("$ make something-weird")
                    .foregroundColor(Color.white.opacity(0.33))
                if demoFailure {
                    Text("make: *** No rule to make target 'something-weird'. Stop.")
                        .foregroundColor(.red.opacity(0.72))
                } else {
                    Text("Build complete. The creature approves.")
                        .foregroundColor(Color.white.opacity(0.52))
                }
                PromptPreview(
                    settings: model.customization.prompt,
                    showCursor: true,
                    simulatedFailure: demoFailure
                )
            }
            .font(.system(size: 12, design: .monospaced))
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(AppTheme.terminal)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(AppTheme.border))
    }

    private func promptBinding<Value>(_ keyPath: WritableKeyPath<PromptSettings, Value>) -> Binding<Value> {
        Binding(
            get: { model.customization.prompt[keyPath: keyPath] },
            set: { newValue in
                var changed = model.customization
                changed.prompt[keyPath: keyPath] = newValue
                model.customization = changed
            }
        )
    }

    private func setPromptStyle(_ style: PromptStyle) {
        var changed = model.customization
        changed.prompt.style = style
        model.customization = changed
    }
}

private struct PromptOption: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 10, weight: .semibold))
                Text(detail).font(.system(size: 8, design: .monospaced)).foregroundColor(AppTheme.secondaryText)
            }
        }
        .toggleStyle(.switch)
        .tint(AppTheme.accent)
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, minHeight: 42)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(AppTheme.border))
    }
}

struct PromptPreview: View {
    let settings: PromptSettings
    var showCursor = false
    var simulatedFailure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !settings.enabled {
                cursorLine(Text("you@mac ~ % ").foregroundColor(Color.white.opacity(0.76)))
            } else {
                if settings.errorReactions && simulatedFailure {
                    Text("Kernel: bold strategy. The exit code disagrees.")
                        .foregroundColor(settings.secondaryTint.color.opacity(0.78))
                }
                switch settings.style {
                case .minimal:
                    cursorLine(metadataText + Text("  ") + symbolText)
                case .twoLine:
                    metadataText
                    cursorLine(symbolText + Text(" "))
                case .capsule:
                    Text("╭─[") + metadataText + Text("]")
                    cursorLine(Text("╰─") + symbolText + Text(" "))
                case .operatorStyle:
                    Text("┌ SYSTEM // ").foregroundColor(settings.primaryTint.color)
                        + metadataText
                    cursorLine(Text("└─ ") + symbolText + Text(" "))
                }
            }
        }
        .font(.system(size: 12, weight: .medium, design: .monospaced))
    }

    private var metadataText: Text {
        var value = Text("")
        var hasSegment = false
        func separator() -> Text { Text(hasSegment ? " · " : "") }

        if settings.showTime {
            value = value + separator() + Text("09:41").foregroundColor(settings.secondaryTint.color)
            hasSegment = true
        }
        if settings.showUserHost {
            value = value + separator() + Text("bragi@mac").foregroundColor(settings.primaryTint.color)
            hasSegment = true
        }
        if settings.showCWD {
            value = value + separator() + Text("~/Coding/TerminalPet").foregroundColor(settings.secondaryTint.color)
            hasSegment = true
        }
        if settings.showGitBranch {
            value = value + separator() + Text("git:main").foregroundColor(settings.primaryTint.color)
            hasSegment = true
        }
        if settings.showExitStatus && simulatedFailure {
            value = value + separator() + Text("✕ 2").foregroundColor(.red)
        }
        return value
    }

    private var symbolText: Text {
        Text(settings.symbol.isEmpty ? "❯" : settings.symbol)
            .bold()
            .foregroundColor(simulatedFailure ? .red : settings.primaryTint.color)
    }

    @ViewBuilder
    private func cursorLine(_ text: Text) -> some View {
        HStack(spacing: 0) {
            text
            if showCursor {
                Rectangle()
                    .fill(Color.white.opacity(0.78))
                    .frame(width: 7, height: 15)
            }
        }
    }
}
