import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
final class AppModel: ObservableObject {
    @Published var section: AppSection = .petStudio
    @Published var selectedPetID: String { didSet { save() } }
    @Published var customPets: [TerminalPet] { didSet { save() } }
    @Published var enabledPetIDs: Set<String> { didSet { save() } }
    @Published var petSelectionMode: PetSelectionMode { didSet { save() } }
    @Published var enabledOpenerIDs: Set<String> { didSet { save() } }
    @Published var customOpeners: [TerminalOpener] { didSet { save() } }
    @Published var tint: TerminalTint { didSet { save() } }
    @Published var showPetName: Bool { didSet { save() } }
    @Published var customization: CustomizationSettings { didSet { save() } }
    @Published var installZsh: Bool { didSet { save() } }
    @Published var installBash: Bool { didSet { save() } }
    @Published var installState: InstallState = .checking
    @Published var notice: String?

    private static let defaultsKey = "terminal-pet-settings-v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let stored = try? JSONDecoder().decode(StoredSettings.self, from: data) {
            selectedPetID = stored.selectedPetID
            customPets = stored.customPets
            enabledPetIDs = Set(stored.enabledPetIDs ?? [stored.selectedPetID])
            petSelectionMode = stored.petSelectionMode ?? .fixed
            enabledOpenerIDs = Set(stored.enabledOpenerIDs)
            customOpeners = stored.customOpeners
            tint = stored.tint
            showPetName = stored.showPetName
            var migratedCustomization = stored.customization ?? CustomizationSettings()
            if stored.customization == nil && !stored.showDivider {
                migratedCustomization.dividerStyle = .none
            }
            customization = migratedCustomization
            installZsh = stored.installZsh
            installBash = stored.installBash
        } else {
            let firstPet = PetLibrary.pets[0]
            selectedPetID = firstPet.id
            customPets = []
            enabledPetIDs = [firstPet.id]
            petSelectionMode = .fixed
            enabledOpenerIDs = Set(PetLibrary.openers.map(\.id))
            customOpeners = []
            tint = .phosphor
            showPetName = true
            customization = CustomizationSettings()
            installZsh = true
            installBash = false
        }

        if !allPets.contains(where: { $0.id == selectedPetID }) {
            selectedPetID = PetLibrary.pets[0].id
        }
        let availablePetIDs = Set(allPets.map(\.id))
        enabledPetIDs.formIntersection(availablePetIDs)
        if enabledPetIDs.isEmpty { enabledPetIDs.insert(selectedPetID) }
        refreshInstallState()
    }

    var allPets: [TerminalPet] { PetLibrary.pets + customPets }
    var allOpeners: [TerminalOpener] { PetLibrary.openers + customOpeners }

    var selectedPet: TerminalPet {
        allPets.first(where: { $0.id == selectedPetID }) ?? PetLibrary.pets[0]
    }

    var enabledOpeners: [TerminalOpener] {
        allOpeners.filter { enabledOpenerIDs.contains($0.id) }
    }

    var rotationPets: [TerminalPet] {
        allPets.filter { enabledPetIDs.contains($0.id) }
    }

    var showDivider: Bool {
        get { customization.dividerStyle != .none }
        set { customization.dividerStyle = newValue ? .line : .none }
    }

    var installConfiguration: InstallConfiguration {
        let pets: [TerminalPet]
        if petSelectionMode == .rotation {
            pets = rotationPets.isEmpty ? [selectedPet] : rotationPets
        } else {
            pets = [selectedPet]
        }
        return InstallConfiguration(
            pets: pets,
            openers: enabledOpeners,
            tint: tint,
            showPetName: showPetName,
            customization: customization,
            installZsh: installZsh,
            installBash: installBash
        )
    }

    func addPet(name: String, art: String) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let pet = TerminalPet(
            id: "custom-\(UUID().uuidString.lowercased())",
            name: cleanName.isEmpty ? "New friend" : cleanName,
            art: art,
            isCustom: true
        )
        customPets.append(pet)
        enabledPetIDs.insert(pet.id)
        selectedPetID = pet.id
        notice = "\(pet.name) joined the terminal."
    }

    func removeSelectedCustomPet() {
        guard selectedPet.isCustom else { return }
        let removedID = selectedPetID
        customPets.removeAll { $0.id == removedID }
        enabledPetIDs.remove(removedID)
        selectedPetID = PetLibrary.pets[0].id
        if enabledPetIDs.isEmpty { enabledPetIDs.insert(selectedPetID) }
        notice = "Custom pet removed."
    }

    func togglePetInRotation(_ pet: TerminalPet) {
        if enabledPetIDs.contains(pet.id) {
            if enabledPetIDs.count > 1 { enabledPetIDs.remove(pet.id) }
        } else {
            enabledPetIDs.insert(pet.id)
        }
    }

    func enableEveryPet() {
        enabledPetIDs = Set(allPets.map(\.id))
    }

    func toggleOpener(_ opener: TerminalOpener) {
        if enabledOpenerIDs.contains(opener.id) {
            enabledOpenerIDs.remove(opener.id)
        } else {
            enabledOpenerIDs.insert(opener.id)
        }
    }

    func setMood(_ mood: OpenerMood, enabled: Bool) {
        let ids = allOpeners.filter { $0.mood == mood }.map(\.id)
        if enabled { enabledOpenerIDs.formUnion(ids) }
        else { enabledOpenerIDs.subtract(ids) }
    }

    func addCustomOpener(_ text: String, mood: OpenerMood) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let opener = TerminalOpener(
            id: "custom-opener-\(UUID().uuidString.lowercased())",
            text: clean,
            mood: mood,
            isCustom: true
        )
        customOpeners.append(opener)
        enabledOpenerIDs.insert(opener.id)
    }

    func removeCustomOpener(_ opener: TerminalOpener) {
        guard opener.isCustom else { return }
        customOpeners.removeAll { $0.id == opener.id }
        enabledOpenerIDs.remove(opener.id)
    }

    func randomPreviewOpener() -> TerminalOpener? { enabledOpeners.randomElement() }

    func applyPreset(_ preset: TerminalPreset) {
        tint = preset.tint
        customization = preset.settings
        if preset.id == "chaos-engine" {
            petSelectionMode = .rotation
            enableEveryPet()
        }
        notice = "\(preset.name) loaded. Tweak anything you want."
    }

    func surpriseMe() {
        guard let preset = PresetLibrary.presets.randomElement() else { return }
        applyPreset(preset)
        let colors = TerminalTint.allCases
        if let randomTint = colors.randomElement() { tint = randomTint }
        notice = "The machine chose \(preset.name), then ignored one instruction."
    }

    func install() {
        guard installZsh || installBash else {
            installState = .error("Choose zsh, bash, or both.")
            return
        }
        do {
            try ShellInstaller.install(configuration: installConfiguration)
            refreshInstallState()
            notice = "Terminal Pet is live. Open a new terminal window."
        } catch {
            installState = .error(error.localizedDescription)
        }
    }

    func uninstall() {
        do {
            try ShellInstaller.uninstall()
            refreshInstallState()
            notice = "Terminal Pet was removed from your shell startup."
        } catch {
            installState = .error(error.localizedDescription)
        }
    }

    func refreshInstallState() { installState = ShellInstaller.currentState() }

    func revealInstallFolder() {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".terminal-pet", isDirectory: true)
        NSWorkspace.shared.open(url)
    }

    func exportConfiguration() {
        let panel = NSSavePanel()
        panel.title = "Export Terminal Pet setup"
        panel.nameFieldStringValue = "My-Terminal-Pet.terminalpet.json"
        panel.allowedContentTypes = [.json]
        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let bundle = ShareableConfiguration(
                formatVersion: 2,
                exportedAt: Date(),
                settings: currentStoredSettings()
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(bundle).write(to: url, options: .atomic)
            notice = "Setup exported. Hand it to another Mac gremlin."
        } catch {
            notice = "Export failed: \(error.localizedDescription)"
        }
    }

    func importConfiguration() {
        let panel = NSOpenPanel()
        panel.title = "Import Terminal Pet setup"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json, .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let imported = try decoder.decode(ShareableConfiguration.self, from: data)
            applyImportedSettings(imported.settings)
            notice = "Imported. Review it, then install the update."
        } catch {
            notice = "That setup file is not valid Terminal Pet JSON."
        }
    }

    private func applyImportedSettings(_ stored: StoredSettings) {
        customPets = stored.customPets
        customOpeners = stored.customOpeners
        enabledOpenerIDs = Set(stored.enabledOpenerIDs)
        tint = stored.tint
        showPetName = stored.showPetName
        installZsh = stored.installZsh
        installBash = stored.installBash
        customization = stored.customization ?? CustomizationSettings()
        petSelectionMode = stored.petSelectionMode ?? .fixed

        let validPets = PetLibrary.pets + stored.customPets
        let validIDs = Set(validPets.map(\.id))
        selectedPetID = validIDs.contains(stored.selectedPetID)
            ? stored.selectedPetID
            : PetLibrary.pets[0].id
        enabledPetIDs = Set(stored.enabledPetIDs ?? [selectedPetID]).intersection(validIDs)
        if enabledPetIDs.isEmpty { enabledPetIDs.insert(selectedPetID) }
    }

    private func currentStoredSettings() -> StoredSettings {
        StoredSettings(
            selectedPetID: selectedPetID,
            customPets: customPets,
            enabledOpenerIDs: Array(enabledOpenerIDs),
            customOpeners: customOpeners,
            tint: tint,
            showPetName: showPetName,
            showDivider: showDivider,
            installZsh: installZsh,
            installBash: installBash,
            petSelectionMode: petSelectionMode,
            enabledPetIDs: Array(enabledPetIDs),
            customization: customization
        )
    }

    private func save() {
        if let data = try? JSONEncoder().encode(currentStoredSettings()) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }
}
