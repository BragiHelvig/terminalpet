import Foundation
import SwiftUI

struct OpenersView: View {
    @EnvironmentObject private var model: AppModel
    @State private var customText = ""
    @State private var customMood: OpenerMood = .chaotic

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .bottom) {
                SectionTitle(
                    eyebrow: "03 / Voice",
                    title: "Give it something to say",
                    subtitle: "One enabled line is chosen at random whenever a new terminal opens."
                )
                Spacer()
                Text("\(model.enabledOpeners.count) ENABLED")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(AppTheme.accent)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(AppTheme.accent.opacity(0.08)))
            }

            composer

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(OpenerMood.allCases) { mood in
                        MoodSection(mood: mood)
                            .environmentObject(model)
                    }
                }
                .padding(.bottom, 4)
            }
        }
        .padding(.top, 42)
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
        .background(AppTheme.background)
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Label("Write your own", systemImage: "plus.bubble.fill")
                    .font(.system(size: 12, weight: .semibold))
                Spacer()
                Text("TOKENS  {user}  {pet}  {host}  {cwd}")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
            }
            HStack(spacing: 10) {
                TextField("e.g. {pet} says the build has immaculate vibes.", text: $customText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addCustom)
                Picker("Mood", selection: $customMood) {
                    ForEach(OpenerMood.allCases) { mood in
                        Text(mood.rawValue).tag(mood)
                    }
                }
                .labelsHidden()
                .frame(width: 150)
                Button("Add", action: addCustom)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundColor(.black)
                    .disabled(customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .terminalCard(padding: 15)
    }

    private func addCustom() {
        model.addCustomOpener(customText, mood: customMood)
        customText = ""
    }
}

private struct MoodSection: View {
    @EnvironmentObject private var model: AppModel
    let mood: OpenerMood

    private var openers: [TerminalOpener] {
        model.allOpeners.filter { $0.mood == mood }
    }

    private var allEnabled: Bool {
        !openers.isEmpty && openers.allSatisfy { model.enabledOpenerIDs.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 9) {
                Image(systemName: mood.symbol)
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 18)
                Text(mood.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                Text("\(openers.filter { model.enabledOpenerIDs.contains($0.id) }.count)/\(openers.count)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Button(allEnabled ? "Disable set" : "Enable set") {
                    model.setMood(mood, enabled: !allEnabled)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.accent)
            }
            .padding(.horizontal, 15)
            .frame(height: 42)
            .background(AppTheme.panelRaised.opacity(0.65))

            ForEach(Array(openers.enumerated()), id: \.element.id) { index, opener in
                HStack(spacing: 12) {
                    Toggle("", isOn: Binding(
                        get: { model.enabledOpenerIDs.contains(opener.id) },
                        set: { _ in model.toggleOpener(opener) }
                    ))
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(AppTheme.accent)
                    .controlSize(.small)

                    Text(opener.text)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(model.enabledOpenerIDs.contains(opener.id) ? AppTheme.text : AppTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if opener.isCustom {
                        Button(role: .destructive) {
                            model.removeCustomOpener(opener)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.red.opacity(0.76))
                    }
                }
                .padding(.horizontal, 15)
                .frame(minHeight: 40)

                if index < openers.count - 1 {
                    Rectangle()
                        .fill(AppTheme.border)
                        .frame(height: 1)
                        .padding(.leading, 60)
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(AppTheme.panel))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(AppTheme.border, lineWidth: 1)
        )
    }
}
