import SwiftUI

struct ASCIIEditorView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var art = #"""
     /\_/\
    (     )
     >   <
    """#

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("RAW ASCII LAB")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(1.4)
                        .foregroundColor(AppTheme.accent)
                    Text("Paste, draw, or summon a creature")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 19))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(22)

            Rectangle().fill(AppTheme.border).frame(height: 1)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("EDIT")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.secondaryText)
                    TextEditor(text: $art)
                        .font(.system(size: 13, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .background(AppTheme.terminal)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.border))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("PREVIEW")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.secondaryText)
                    ScrollView([.horizontal, .vertical]) {
                        Text(cleanArt)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(model.tint.color)
                            .fixedSize()
                            .padding(18)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .background(AppTheme.terminal)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(AppTheme.border))
                }
            }
            .padding(20)

            HStack(spacing: 12) {
                TextField("Pet name", text: $name)
                    .textFieldStyle(.roundedBorder)
                Text("Tabs become four spaces · control characters are stripped on install")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(AppTheme.secondaryText)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)
                Button {
                    model.addPet(name: name, art: cleanArt)
                    dismiss()
                } label: {
                    Label("Add creature", systemImage: "pawprint.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .foregroundColor(.black)
                .disabled(cleanArt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
            .background(AppTheme.panel)
        }
        .frame(width: 820, height: 560)
        .background(AppTheme.background)
        .foregroundColor(AppTheme.text)
    }

    private var cleanArt: String {
        art.replacingOccurrences(of: "\t", with: "    ")
    }
}
