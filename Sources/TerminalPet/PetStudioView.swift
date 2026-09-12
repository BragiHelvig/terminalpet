import Foundation
import SwiftUI

struct PetStudioView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showingImporter = false
    @State private var showingASCIIEditor = false
    @State private var previewTemplate = "No errors yet. Suspicious."

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .bottom) {
                SectionTitle(
                    eyebrow: "01 / Creature",
                    title: "Choose your terminal familiar",
                    subtitle: "Pick a built-in menace or turn a photo into terminal-safe ASCII."
                )
                Spacer()
                HStack(spacing: 9) {
                    Button {
                        showingASCIIEditor = true
                    } label: {
                        Label("Paste ASCII", systemImage: "text.cursor")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import image", systemImage: "photo.badge.plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundColor(.black)
                    .controlSize(.large)
                }
            }

            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 16) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(model.allPets) { pet in
                                PetCard(
                                    pet: pet,
                                    selected: pet.id == model.selectedPetID,
                                    tint: model.tint.color
                                ) {
                                    model.selectedPetID = pet.id
                                }
                            }
                        }
                        .padding(1)
                    }

                    HStack {
                        Text("PHOSPHOR COLOR")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(1)
                            .foregroundColor(AppTheme.secondaryText)
                        Spacer()
                        if model.selectedPet.isCustom {
                            Button(role: .destructive) {
                                model.removeSelectedCustomPet()
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.red.opacity(0.85))
                        }
                    }

                    HStack(spacing: 10) {
                        ForEach(TerminalTint.allCases) { tint in
                            Button {
                                model.tint = tint
                            } label: {
                                Circle()
                                    .fill(tint.color)
                                    .frame(width: 21, height: 21)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: model.tint == tint ? 2 : 0)
                                            .padding(-4)
                                    )
                            }
                            .buttonStyle(.plain)
                            .help(tint.title)
                        }
                    }
                }
                .frame(minWidth: 340, idealWidth: 390, maxWidth: 440)
                .terminalCard()

                TerminalPreview(
                    pet: model.selectedPet,
                    line: expandedPreviewLine,
                    tint: model.tint,
                    showPetName: model.showPetName,
                    showDivider: model.showDivider,
                    reroll: rerollPreview
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.top, 42)
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
        .background(AppTheme.background)
        .sheet(isPresented: $showingImporter) {
            ImageImportView()
                .environmentObject(model)
        }
        .sheet(isPresented: $showingASCIIEditor) {
            ASCIIEditorView()
                .environmentObject(model)
        }
        .onAppear(perform: rerollPreview)
    }

    private func rerollPreview() {
        previewTemplate = model.randomPreviewOpener()?.text ?? ""
    }

    private var expandedPreviewLine: String {
        previewTemplate
            .replacingOccurrences(of: "{user}", with: NSUserName())
            .replacingOccurrences(of: "{host}", with: Host.current().localizedName ?? "this-mac")
            .replacingOccurrences(of: "{cwd}", with: "~/somewhere-interesting")
            .replacingOccurrences(of: "{pet}", with: model.selectedPet.name)
    }
}

private struct PetCard: View {
    let pet: TerminalPet
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(pet.art)
                        .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                        .foregroundColor(selected ? tint : AppTheme.secondaryText)
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(minHeight: 58, alignment: .center)
                }
                Text(pet.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .lineLimit(1)
                Text(pet.isCustom ? "CUSTOM" : "BUILT IN")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(selected ? tint.opacity(0.85) : AppTheme.secondaryText.opacity(0.7))
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 122, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? tint.opacity(0.075) : AppTheme.panelRaised.opacity(0.65))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(selected ? tint.opacity(0.78) : AppTheme.border, lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TerminalPreview: View {
    let pet: TerminalPet
    let line: String
    let tint: TerminalTint
    let showPetName: Bool
    let showDivider: Bool
    let reroll: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Circle().fill(Color.red.opacity(0.86)).frame(width: 10, height: 10)
                Circle().fill(Color.yellow.opacity(0.86)).frame(width: 10, height: 10)
                Circle().fill(Color.green.opacity(0.86)).frame(width: 10, height: 10)
                Spacer()
                Text("zsh — 80×24")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Button(action: reroll) {
                    Image(systemName: "dice.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
                .help("Try another opener")
            }
            .padding(.horizontal, 14)
            .frame(height: 38)
            .background(Color.white.opacity(0.035))

            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last login: a moment ago on ttys001")
                        .foregroundColor(Color.white.opacity(0.30))

                    Text(pet.art)
                        .foregroundColor(tint.color)
                        .shadow(color: tint.color.opacity(0.22), radius: 8)

                    if showDivider {
                        Text("────────────────────────────────────")
                            .foregroundColor(Color.white.opacity(0.21))
                    }

                    if showPetName {
                        (Text(pet.name).bold() + Text("  " + line))
                            .foregroundColor(Color.white.opacity(0.89))
                    } else {
                        Text(line)
                            .foregroundColor(Color.white.opacity(0.89))
                    }

                    HStack(spacing: 0) {
                        Text("you@mac ~ % ")
                            .foregroundColor(tint.color.opacity(0.9))
                        Rectangle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 7, height: 15)
                    }
                }
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
        }
        .background(AppTheme.terminal)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 24, y: 14)
    }
}
