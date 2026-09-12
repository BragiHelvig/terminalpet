import AppKit
import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var model: AppModel
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .bottom) {
                SectionTitle(
                    eyebrow: "05 / Deploy",
                    title: "Install, share, unleash",
                    subtitle: "Generate the scene and optional prompt, or export the entire setup as JSON."
                )
                Spacer()
                StatusPill(state: model.installState)
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 16) {
                    shellCard
                    displayCard
                    shareCard
                }
                .frame(maxWidth: .infinity)

                installCard
                    .frame(width: 330)
            }

            safetyNote
        }
        .padding(.top, 42)
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
        .background(AppTheme.background)
    }

    private var shellCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Shells", systemImage: "terminal")
                .font(.system(size: 13, weight: .semibold))

            ShellToggle(
                title: "zsh",
                detail: "macOS default · ~/.zshrc",
                isOn: $model.installZsh
            )
            ShellToggle(
                title: "bash",
                detail: "Optional · interactive + login startup",
                isOn: $model.installBash
            )
        }
        .terminalCard()
    }

    private var displayCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("Payload", systemImage: "shippingbox.fill")
                .font(.system(size: 13, weight: .semibold))

            Toggle(isOn: $model.showPetName) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show pet name")
                        .font(.system(size: 12, weight: .medium))
                    Text("Prints \(model.selectedPet.name) before the opener")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .toggleStyle(.switch)
            .tint(AppTheme.accent)

            HStack {
                PayloadStat(value: model.petSelectionMode == .rotation ? "\(model.rotationPets.count) rotating" : model.selectedPet.name, label: "PETS")
                PayloadStat(value: "\(model.enabledOpeners.count)", label: "OPENERS")
                PayloadStat(value: model.customization.introEffect.rawValue, label: "EFFECT")
                PayloadStat(value: model.customization.prompt.enabled ? model.customization.prompt.style.rawValue : "Off", label: "PROMPT")
            }
        }
        .terminalCard()
    }

    private var shareCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("Portable setup", systemImage: "square.and.arrow.up.on.square")
                .font(.system(size: 13, weight: .semibold))
            Text("Export pets, openers, colors, modules, rules, and prompt settings. The file contains no shell history or personal terminal data.")
                .font(.system(size: 10))
                .foregroundColor(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(action: model.exportConfiguration) {
                    Label("Export setup", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                Button(action: model.importConfiguration) {
                    Label("Import setup", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
            }
        }
        .terminalCard()
    }

    private var installCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(model.tint.color.opacity(0.09))
                Text(model.selectedPet.art)
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundColor(model.tint.color)
                    .lineLimit(8)
                    .minimumScaleFactor(0.65)
                    .padding(12)
            }
            .frame(maxWidth: .infinity, minHeight: 130)

            VStack(alignment: .leading, spacing: 5) {
                Text(model.installState.isInstalled ? "READY TO UPDATE" : "READY TO INSTALL")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(AppTheme.accent)
                Text("\(model.petSelectionMode == .rotation ? "Pet roulette" : model.selectedPet.name) + \(model.enabledOpeners.count) opener\(model.enabledOpeners.count == 1 ? "" : "s")")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text("Changes appear in the next terminal window you open.")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.secondaryText)
            }

            if case .error(let message) = model.installState {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.red.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                model.install()
            } label: {
                HStack {
                    Image(systemName: model.installState.isInstalled ? "arrow.triangle.2.circlepath" : "bolt.fill")
                    Text(model.installState.isInstalled ? "Install update" : "Install Terminal Pet")
                    Spacer()
                    Text("⌘↩")
                        .font(.system(size: 10, design: .monospaced))
                        .opacity(0.65)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
            .foregroundColor(.black)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!model.installZsh && !model.installBash)

            HStack {
                Button {
                    copyHook()
                } label: {
                    Label(copied ? "Copied" : "Copy hook", systemImage: copied ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.secondaryText)

                Spacer()

                if model.installState.isInstalled {
                    Button("Reveal files") { model.revealInstallFolder() }
                        .buttonStyle(.plain)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .font(.system(size: 10, weight: .medium))

            if model.installState.isInstalled {
                Rectangle().fill(AppTheme.border).frame(height: 1)
                Button(role: .destructive) {
                    model.uninstall()
                } label: {
                    Label("Uninstall cleanly", systemImage: "trash")
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.red.opacity(0.82))
            }
        }
        .terminalCard()
    }

    private var safetyNote: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(AppTheme.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text("Civilized shell manners")
                    .font(.system(size: 11, weight: .semibold))
                Text("Terminal Pet adds one clearly marked block and keeps a one-time pre-install backup. Generated scene and prompt scripts live only in ~/.terminal-pet. Uninstall removes its block and generated files without touching the rest of your shell config.")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(AppTheme.accent.opacity(0.045)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(AppTheme.accent.opacity(0.15), lineWidth: 1)
        )
    }

    private func copyHook() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(ShellInstaller.manualHook(), forType: .string)
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            copied = false
        }
    }
}

private struct PayloadStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .lineLimit(1)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ShellToggle: View {
    let title: String
    let detail: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.black.opacity(0.28))
                    Text(">_")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(isOn ? AppTheme.accent : AppTheme.secondaryText)
                }
                .frame(width: 34, height: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    Text(detail)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .toggleStyle(.switch)
        .tint(AppTheme.accent)
    }
}
