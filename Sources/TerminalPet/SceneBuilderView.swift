import Foundation
import SwiftUI

struct SceneBuilderView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .bottom) {
                SectionTitle(
                    eyebrow: "02 / Scene",
                    title: "Build the opening ritual",
                    subtitle: "Theme it, animate it, add live system modules, then decide when it appears."
                )
                Spacer()
                Button(action: model.surpriseMe) {
                    Label("Surprise me", systemImage: "die.face.5.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .foregroundColor(.black)
                .controlSize(.large)
            }

            presetStrip

            HStack(alignment: .top, spacing: 18) {
                ScrollView {
                    VStack(spacing: 14) {
                        appearanceCard
                        modulesCard
                        rulesCard
                    }
                    .padding(1)
                }
                .frame(minWidth: 430, idealWidth: 480, maxWidth: 520)

                AdvancedScenePreview()
                    .environmentObject(model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 42)
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
        .background(AppTheme.background)
    }

    private var presetStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(PresetLibrary.presets) { preset in
                    Button { model.applyPreset(preset) } label: {
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(preset.tint.color.opacity(0.13))
                                Image(systemName: preset.symbol)
                                    .foregroundColor(preset.tint.color)
                            }
                            .frame(width: 36, height: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.name)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(AppTheme.text)
                                Text(preset.detail)
                                    .font(.system(size: 9))
                                    .foregroundColor(AppTheme.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal, 11)
                        .frame(width: 240, height: 54, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AppTheme.panel))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.border))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeading(symbol: "paintpalette.fill", title: "Appearance", detail: "Colors, creature rotation, and theatrical nonsense")

            LabeledControl("PET SELECTION") {
                Picker("", selection: $model.petSelectionMode) {
                    ForEach(PetSelectionMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }

            if model.petSelectionMode == .rotation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ROULETTE POOL")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.secondaryText)
                        Spacer()
                        Button("Enable all", action: model.enableEveryPet)
                            .buttonStyle(.plain)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }
                    FlowPetPicker()
                        .environmentObject(model)
                }
            }

            HStack(spacing: 12) {
                LabeledControl("COLOR MODE") {
                    Picker("", selection: binding(\.petColorMode)) {
                        ForEach(PetColorMode.allCases) { mode in Text(mode.rawValue).tag(mode) }
                    }
                    .labelsHidden()
                }
                LabeledControl("DIVIDER") {
                    Picker("", selection: binding(\.dividerStyle)) {
                        ForEach(DividerStyle.allCases) { style in Text(style.rawValue).tag(style) }
                    }
                    .labelsHidden()
                }
            }

            TintChooser(title: "PET", selection: $model.tint)
            TintChooser(title: "SECONDARY", selection: binding(\.secondaryTint))
            TintChooser(title: "OPENER", selection: binding(\.openerTint))
            TintChooser(title: "SYSTEM INFO", selection: binding(\.metadataTint))

            HStack(spacing: 12) {
                LabeledControl("INTRO EFFECT") {
                    Picker("", selection: binding(\.introEffect)) {
                        ForEach(IntroEffect.allCases) { effect in Text(effect.rawValue).tag(effect) }
                    }
                    .labelsHidden()
                }
                LabeledControl("SPEED") {
                    Picker("", selection: binding(\.introSpeed)) {
                        ForEach(IntroSpeed.allCases) { speed in Text(speed.rawValue).tag(speed) }
                    }
                    .labelsHidden()
                }
            }
        }
        .terminalCard(padding: 16)
    }

    private var modulesCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            CardHeading(symbol: "square.grid.2x2.fill", title: "Live modules", detail: "Calculated fresh each time the shell opens")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ModuleSwitch(title: "Clock", symbol: "clock", isOn: binding(\.showClock))
                ModuleSwitch(title: "Date", symbol: "calendar", isOn: binding(\.showDate))
                ModuleSwitch(title: "User + host", symbol: "person.crop.circle", isOn: binding(\.showUserHost))
                ModuleSwitch(title: "Directory", symbol: "folder", isOn: binding(\.showCWD))
                ModuleSwitch(title: "macOS", symbol: "apple.logo", isOn: binding(\.showOS))
                ModuleSwitch(title: "Architecture", symbol: "cpu", isOn: binding(\.showArchitecture))
                ModuleSwitch(title: "Shell", symbol: "terminal", isOn: binding(\.showShell))
                ModuleSwitch(title: "Battery", symbol: "battery.75", isOn: binding(\.showBattery))
                ModuleSwitch(title: "Uptime", symbol: "timer", isOn: binding(\.showUptime))
                ModuleSwitch(title: "Git branch", symbol: "arrow.triangle.branch", isOn: binding(\.showGitBranch))
            }
        }
        .terminalCard(padding: 16)
    }

    private var rulesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            CardHeading(symbol: "switch.2", title: "Session rules", detail: "Control where and how often the ritual runs")

            HStack(spacing: 12) {
                LabeledControl("FREQUENCY") {
                    Picker("", selection: binding(\.frequency)) {
                        ForEach(DisplayFrequency.allCases) { item in Text(item.rawValue).tag(item) }
                    }
                    .labelsHidden()
                }
                LabeledControl("WHERE") {
                    Picker("", selection: binding(\.sessionScope)) {
                        ForEach(SessionScope.allCases) { item in Text(item.rawValue).tag(item) }
                    }
                    .labelsHidden()
                }
            }

            RuleToggle(title: "Skip IDE terminals", detail: "Stay out of VS Code and JetBrains terminals", isOn: binding(\.skipIDETerminals))
            RuleToggle(title: "Respect NO_COLOR", detail: "Use plain output when that environment variable is set", isOn: binding(\.respectNoColor))
            RuleToggle(title: "Terminal bell", detail: "One tiny audible ding after the intro", isOn: binding(\.terminalBell))
            RuleToggle(title: "Set window title", detail: "Supports {pet}, {user}, {host}, and {cwd}", isOn: binding(\.setWindowTitle))

            if model.customization.setWindowTitle {
                TextField("{pet} · {cwd}", text: binding(\.windowTitle))
                    .textFieldStyle(.roundedBorder)
            }

            RuleToggle(title: "Quiet hours", detail: "Do not summon anything during the chosen hours", isOn: binding(\.quietHoursEnabled))
            if model.customization.quietHoursEnabled {
                HStack {
                    Stepper("From \(hourLabel(model.customization.quietStart))", value: binding(\.quietStart), in: 0...23)
                    Spacer()
                    Stepper("Until \(hourLabel(model.customization.quietEnd))", value: binding(\.quietEnd), in: 0...23)
                }
                .font(.system(size: 10, design: .monospaced))
            }
        }
        .terminalCard(padding: 16)
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<CustomizationSettings, Value>) -> Binding<Value> {
        Binding(
            get: { model.customization[keyPath: keyPath] },
            set: { newValue in
                var changed = model.customization
                changed[keyPath: keyPath] = newValue
                model.customization = changed
            }
        )
    }

    private func hourLabel(_ hour: Int) -> String {
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }
}

private struct FlowPetPicker: View {
    @EnvironmentObject private var model: AppModel
    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 7)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 7) {
            ForEach(model.allPets) { pet in
                let enabled = model.enabledPetIDs.contains(pet.id)
                Button { model.togglePetInRotation(pet) } label: {
                    HStack(spacing: 5) {
                        Image(systemName: enabled ? "checkmark.circle.fill" : "circle")
                        Text(pet.name).lineLimit(1)
                    }
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(enabled ? model.tint.color : AppTheme.secondaryText)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 7).fill(enabled ? model.tint.color.opacity(0.08) : Color.black.opacity(0.12)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TintChooser: View {
    let title: String
    @Binding var selection: TerminalTint

    var body: some View {
        HStack(spacing: 9) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.secondaryText)
                .frame(width: 76, alignment: .leading)
            ForEach(TerminalTint.allCases) { tint in
                Button { selection = tint } label: {
                    Circle()
                        .fill(tint.color)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().strokeBorder(Color.white, lineWidth: selection == tint ? 1.5 : 0).padding(-3))
                }
                .buttonStyle(.plain)
                .help(tint.title)
            }
        }
    }
}

struct CardHeading: View {
    let symbol: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundColor(AppTheme.accent)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 13, weight: .semibold))
                Text(detail).font(.system(size: 9)).foregroundColor(AppTheme.secondaryText)
            }
            Spacer()
        }
    }
}

private struct LabeledControl<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.secondaryText)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ModuleSwitch: View {
    let title: String
    let symbol: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: symbol)
                .font(.system(size: 10, weight: .medium))
        }
        .toggleStyle(.button)
        .buttonStyle(.plain)
        .foregroundColor(isOn ? AppTheme.text : AppTheme.secondaryText)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(isOn ? AppTheme.accent.opacity(0.08) : Color.black.opacity(0.12)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(isOn ? AppTheme.accent.opacity(0.25) : AppTheme.border))
    }
}

private struct RuleToggle: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 11, weight: .medium))
                Text(detail).font(.system(size: 9)).foregroundColor(AppTheme.secondaryText)
            }
        }
        .toggleStyle(.switch)
        .tint(AppTheme.accent)
    }
}
