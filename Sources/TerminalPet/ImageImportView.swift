import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ImageImportView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var image: NSImage?
    @State private var petName = ""
    @State private var width = 42.0
    @State private var contrast = 1.2
    @State private var inverted = false
    @State private var removeFlatBackground = true
    @State private var characterSet: ASCIICharacterSet = .classic

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("IMAGE → ASCII")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(1.4)
                        .foregroundColor(AppTheme.accent)
                    Text("Make a new terminal creature")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 19))
                        .foregroundColor(AppTheme.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(22)

            Rectangle().fill(AppTheme.border).frame(height: 1)

            if let image {
                converter(image: image)
            } else {
                emptyState
            }
        }
        .frame(width: 880, height: 620)
        .background(AppTheme.background)
        .foregroundColor(AppTheme.text)
        .onAppear {
            if image == nil { chooseImage() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.09))
                    .frame(width: 100, height: 100)
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(AppTheme.accent)
            }
            Text("Choose a clear photo or illustration")
                .font(.system(size: 17, weight: .semibold))
            Text("High contrast and a simple background make the best tiny terminal beasts.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.secondaryText)
            Button("Choose image…", action: chooseImage)
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .foregroundColor(.black)
                .controlSize(.large)
            Label("Conversion happens completely on this Mac", systemImage: "lock.fill")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(AppTheme.secondaryText)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func converter(image: NSImage) -> some View {
        let settings = ASCIIConversionSettings(
            width: Int(width),
            contrast: contrast,
            inverted: inverted,
            removeFlatBackground: removeFlatBackground,
            characterSet: characterSet
        )
        let art = ImageToASCII.convert(image: image, settings: settings)

        return VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SOURCE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundColor(AppTheme.secondaryText)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppTheme.panel)
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(12)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppTheme.border, lineWidth: 1)
                    )
                    Button("Choose another…", action: chooseImage)
                        .buttonStyle(.plain)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                }
                .frame(width: 250)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("TERMINAL PREVIEW")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(1)
                            .foregroundColor(AppTheme.secondaryText)
                        Spacer()
                        Text("\(Int(width)) cols")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(model.tint.color)
                    }

                    ScrollView([.horizontal, .vertical]) {
                        Text(art)
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundColor(model.tint.color)
                            .fixedSize(horizontal: true, vertical: true)
                            .padding(16)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .background(AppTheme.terminal)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(AppTheme.border, lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxHeight: .infinity)

            VStack(spacing: 12) {
                HStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("WIDTH")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.secondaryText)
                        Slider(value: $width, in: 20...72, step: 1)
                            .tint(AppTheme.accent)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("CONTRAST")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.secondaryText)
                        Slider(value: $contrast, in: 0.55...2.4, step: 0.05)
                            .tint(AppTheme.accent)
                    }
                    Toggle("Invert", isOn: $inverted)
                        .toggleStyle(.switch)
                        .tint(AppTheme.accent)
                    Toggle("Drop flat background", isOn: $removeFlatBackground)
                        .toggleStyle(.switch)
                        .tint(AppTheme.accent)
                }

                HStack(spacing: 14) {
                    Picker("Glyphs", selection: $characterSet) {
                        ForEach(ASCIICharacterSet.allCases) { set in
                            Text(set.rawValue).tag(set)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 360)

                    TextField("Pet name", text: $petName)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        model.addPet(name: petName, art: art)
                        dismiss()
                    } label: {
                        Label("Add pet", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                    .foregroundColor(.black)
                    .disabled(art.isEmpty)
                }
            }
            .padding(15)
            .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(AppTheme.panel))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(AppTheme.border, lineWidth: 1)
            )
        }
        .padding(20)
    }

    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.title = "Choose an image for your terminal pet"
        panel.prompt = "Convert"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image]
        panel.begin { response in
            guard response == .OK, let url = panel.url, let selected = NSImage(contentsOf: url) else {
                return
            }
            image = selected
            if petName.isEmpty {
                petName = url.deletingPathExtension().lastPathComponent
            }
        }
    }
}
