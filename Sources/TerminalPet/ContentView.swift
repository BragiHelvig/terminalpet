import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                Sidebar()
                    .frame(width: 220)

                Rectangle()
                    .fill(AppTheme.border)
                    .frame(width: 1)

                Group {
                    switch model.section {
                    case .petStudio:
                        PetStudioView()
                    case .sceneBuilder:
                        SceneBuilderView()
                    case .openers:
                        OpenersView()
                    case .promptLab:
                        PromptLabView()
                    case .setup:
                        SetupView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let notice = model.notice {
                Toast(text: notice)
                    .padding(.top, 14)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .background(AppTheme.background)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: model.notice)
        .onChange(of: model.notice) { value in
            guard let value else { return }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_700_000_000)
                if model.notice == value { model.notice = nil }
            }
        }
    }
}

private struct Sidebar: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(AppTheme.accent)
                    Text(">_")
                        .font(.system(size: 15, weight: .black, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.78))
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 1) {
                    Text("TERMINAL PET")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .tracking(0.7)
                    Text("make the shell alive")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 42)
            .padding(.bottom, 26)

            VStack(spacing: 6) {
                ForEach(AppSection.allCases) { section in
                    SidebarButton(
                        section: section,
                        selected: model.section == section,
                        action: { model.section = section }
                    )
                }
            }
            .padding(.horizontal, 12)

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                StatusPill(state: model.installState)
                Text("Runs locally · no account\nNo pet data leaves this Mac")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText.opacity(0.78))
                    .lineSpacing(3)
            }
            .padding(18)
        }
        .foregroundColor(AppTheme.text)
        .background(AppTheme.sidebar)
    }
}

private struct SidebarButton: View {
    let section: AppSection
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                Image(systemName: section.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 18)
                Text(section.rawValue)
                    .font(.system(size: 13, weight: selected ? .semibold : .medium))
                Spacer()
            }
            .foregroundColor(selected ? AppTheme.text : AppTheme.secondaryText)
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(selected ? AppTheme.panelRaised : Color.clear)
            )
            .overlay(alignment: .leading) {
                if selected {
                    Capsule()
                        .fill(AppTheme.accent)
                        .frame(width: 3, height: 19)
                        .offset(x: -1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct Toast: View {
    let text: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppTheme.accent)
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(red: 0.10, green: 0.12, blue: 0.13))
                .shadow(color: .black.opacity(0.45), radius: 20, y: 7)
        )
        .overlay(Capsule().strokeBorder(AppTheme.border, lineWidth: 1))
    }
}
