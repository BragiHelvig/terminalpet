import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.045, green: 0.052, blue: 0.061)
    static let sidebar = Color(red: 0.065, green: 0.074, blue: 0.087)
    static let panel = Color(red: 0.082, green: 0.093, blue: 0.108)
    static let panelRaised = Color(red: 0.105, green: 0.118, blue: 0.137)
    static let border = Color.white.opacity(0.09)
    static let text = Color.white.opacity(0.94)
    static let secondaryText = Color.white.opacity(0.55)
    static let accent = Color(red: 0.49, green: 1.0, blue: 0.60)
    static let terminal = Color(red: 0.022, green: 0.031, blue: 0.034)
}

struct CardModifier: ViewModifier {
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            )
    }
}

extension View {
    func terminalCard(padding: CGFloat = 18) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

struct SectionTitle: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.4)
                .foregroundColor(AppTheme.accent)
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.secondaryText)
        }
    }
}

struct StatusPill: View {
    let state: InstallState

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .shadow(color: color.opacity(0.7), radius: 4)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.black.opacity(0.24)))
        .overlay(Capsule().strokeBorder(AppTheme.border, lineWidth: 1))
    }

    private var color: Color {
        switch state {
        case .installed: return AppTheme.accent
        case .error: return .red
        case .checking: return .yellow
        case .notInstalled: return AppTheme.secondaryText
        }
    }

    private var label: String {
        switch state {
        case .installed(let shells): return "LIVE · " + shells.joined(separator: " + ")
        case .error: return "NEEDS ATTENTION"
        case .checking: return "CHECKING"
        case .notInstalled: return "NOT INSTALLED"
        }
    }
}
