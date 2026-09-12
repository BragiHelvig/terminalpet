import Foundation

enum ShellInstallerError: LocalizedError {
    case noShellSelected
    case malformedStartupFile(String)

    var errorDescription: String? {
        switch self {
        case .noShellSelected:
            return "Choose at least one shell."
        case .malformedStartupFile(let name):
            return "The existing Terminal Pet block in \(name) is incomplete. Remove it manually, then try again."
        }
    }
}

enum ShellInstaller {
    private static let markerStart = "# >>> Terminal Pet >>>"
    private static let markerEnd = "# <<< Terminal Pet <<<"
    private static let hook = """
    \(markerStart)
    case "$-" in
      *i*)
        if [ "${TERMINAL_PET_SHOWN_PID:-}" != "$$" ] && [ -x "$HOME/.terminal-pet/pet.sh" ]; then
          export TERMINAL_PET_SHOWN_PID="$$"
          "$HOME/.terminal-pet/pet.sh"
        fi
        if [ "${TERMINAL_PET_PROMPT_PID:-}" != "$$" ]; then
          export TERMINAL_PET_PROMPT_PID="$$"
          if [ -n "${ZSH_VERSION:-}" ] && [ -r "$HOME/.terminal-pet/prompt.zsh" ]; then
            . "$HOME/.terminal-pet/prompt.zsh"
          elif [ -n "${BASH_VERSION:-}" ] && [ -r "$HOME/.terminal-pet/prompt.bash" ]; then
            . "$HOME/.terminal-pet/prompt.bash"
          fi
        fi
        ;;
    esac
    \(markerEnd)
    """

    private static var home: URL { FileManager.default.homeDirectoryForCurrentUser }
    private static var supportDirectory: URL { home.appendingPathComponent(".terminal-pet", isDirectory: true) }
    private static var sceneURL: URL { supportDirectory.appendingPathComponent("pet.sh") }
    private static var promptZshURL: URL { supportDirectory.appendingPathComponent("prompt.zsh") }
    private static var promptBashURL: URL { supportDirectory.appendingPathComponent("prompt.bash") }
    private static var snapshotURL: URL { supportDirectory.appendingPathComponent("config.json") }
    private static var dailyStampURL: URL { supportDirectory.appendingPathComponent("last-shown-day") }
    private static var zshrcURL: URL { home.appendingPathComponent(".zshrc") }
    private static var bashrcURL: URL { home.appendingPathComponent(".bashrc") }
    private static var bashProfileURL: URL { home.appendingPathComponent(".bash_profile") }
    private static var bashLoginURL: URL { home.appendingPathComponent(".bash_login") }
    private static var profileURL: URL { home.appendingPathComponent(".profile") }
    private static var bashLoginCandidates: [URL] { [bashProfileURL, bashLoginURL, profileURL] }

    static func install(configuration: InstallConfiguration) throws {
        guard configuration.installZsh || configuration.installBash else {
            throw ShellInstallerError.noShellSelected
        }

        let manager = FileManager.default
        for startupFile in [zshrcURL, bashrcURL] + bashLoginCandidates {
            try preflightStartupFile(startupFile)
        }

        try manager.createDirectory(
            at: supportDirectory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )

        try writeScript(ShellScriptFactory.makeSceneScript(configuration), to: sceneURL, executable: true)

        if configuration.customization.prompt.enabled {
            try writeScript(ShellScriptFactory.makeZshPrompt(configuration), to: promptZshURL, executable: false)
            try writeScript(ShellScriptFactory.makeBashPrompt(configuration), to: promptBashURL, executable: false)
        } else {
            try removeIfPresent(promptZshURL)
            try removeIfPresent(promptBashURL)
        }

        let snapshot = InstalledSnapshot(configuration: configuration)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(snapshot).write(to: snapshotURL, options: .atomic)

        try updateStartupFile(zshrcURL, enabled: configuration.installZsh)
        let loginTarget = preferredBashLoginFile()
        try updateStartupFile(bashrcURL, enabled: configuration.installBash)
        for candidate in bashLoginCandidates {
            let isLoginTarget = candidate.standardizedFileURL == loginTarget.standardizedFileURL
            try updateStartupFile(candidate, enabled: configuration.installBash && isLoginTarget)
        }
    }

    static func uninstall() throws {
        for startupFile in [zshrcURL, bashrcURL] + bashLoginCandidates {
            try preflightStartupFile(startupFile)
        }
        try updateStartupFile(zshrcURL, enabled: false)
        try updateStartupFile(bashrcURL, enabled: false)
        for candidate in bashLoginCandidates { try updateStartupFile(candidate, enabled: false) }

        for url in [sceneURL, promptZshURL, promptBashURL, snapshotURL, dailyStampURL] {
            try removeIfPresent(url)
        }
        try removeSessionStamps()

        let manager = FileManager.default
        if manager.fileExists(atPath: supportDirectory.path),
           (try? manager.contentsOfDirectory(atPath: supportDirectory.path).isEmpty) == true {
            try manager.removeItem(at: supportDirectory)
        }
    }

    static func currentState() -> InstallState {
        let manager = FileManager.default
        guard manager.fileExists(atPath: sceneURL.path) else { return .notInstalled }
        var shells: [String] = []
        if startupFileContainsHook(zshrcURL) { shells.append("zsh") }
        if ([bashrcURL] + bashLoginCandidates).contains(where: { startupFileContainsHook($0) }) {
            shells.append("bash")
        }
        return shells.isEmpty ? .notInstalled : .installed(shells: shells)
    }

    static func manualHook() -> String { hook }

    private static func writeScript(_ content: String, to url: URL, executable: Bool) throws {
        try Data(content.utf8).write(to: url, options: .atomic)
        let permissions = executable ? 0o755 : 0o644
        try FileManager.default.setAttributes([.posixPermissions: permissions], ofItemAtPath: url.path)
    }

    private static func removeIfPresent(_ url: URL) throws {
        let manager = FileManager.default
        if manager.fileExists(atPath: url.path) { try manager.removeItem(at: url) }
    }

    private static func removeSessionStamps() throws {
        let manager = FileManager.default
        guard manager.fileExists(atPath: supportDirectory.path) else { return }
        let files = try manager.contentsOfDirectory(at: supportDirectory, includingPropertiesForKeys: nil)
        for file in files where file.lastPathComponent.hasPrefix("session-") {
            try manager.removeItem(at: file)
        }
    }

    private static func startupFileContainsHook(_ url: URL) -> Bool {
        guard let content = try? String(contentsOf: resolvedURL(url), encoding: .utf8) else { return false }
        return content.contains(markerStart) && content.contains(markerEnd)
    }

    private static func updateStartupFile(_ originalURL: URL, enabled: Bool) throws {
        let manager = FileManager.default
        let exists = manager.fileExists(atPath: originalURL.path)
        if !exists && !enabled { return }

        let targetURL = resolvedURL(originalURL)
        let original = exists ? try String(contentsOf: targetURL, encoding: .utf8) : ""
        let cleaned = try removingHook(from: original, filename: originalURL.lastPathComponent)
        var updated = cleaned

        if enabled {
            if exists && !original.contains(markerStart) {
                try createBackupIfNeeded(content: original, for: originalURL)
            }
            if !updated.isEmpty && !updated.hasSuffix("\n") { updated += "\n" }
            if !updated.isEmpty { updated += "\n" }
            updated += hook + "\n"
        }

        guard updated != original else { return }
        try Data(updated.utf8).write(to: targetURL, options: [])
    }

    private static func removingHook(from content: String, filename: String) throws -> String {
        var result = content
        while let start = result.range(of: markerStart) {
            guard let end = result.range(of: markerEnd, range: start.upperBound..<result.endIndex) else {
                throw ShellInstallerError.malformedStartupFile(filename)
            }
            var lower = start.lowerBound
            if lower > result.startIndex {
                let previous = result.index(before: lower)
                if result[previous] == "\n" { lower = previous }
            }
            var upper = end.upperBound
            if upper < result.endIndex, result[upper] == "\n" { upper = result.index(after: upper) }
            result.removeSubrange(lower..<upper)
        }
        return result
    }

    private static func createBackupIfNeeded(content: String, for startupURL: URL) throws {
        let backup = startupURL.deletingLastPathComponent()
            .appendingPathComponent(startupURL.lastPathComponent + ".pre-terminal-pet")
        guard !FileManager.default.fileExists(atPath: backup.path) else { return }
        try Data(content.utf8).write(to: backup, options: .atomic)
    }

    private static func resolvedURL(_ url: URL) -> URL {
        guard FileManager.default.fileExists(atPath: url.path) else { return url }
        return url.resolvingSymlinksInPath()
    }

    private static func preflightStartupFile(_ url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        let content = try String(contentsOf: resolvedURL(url), encoding: .utf8)
        _ = try removingHook(from: content, filename: url.lastPathComponent)
    }

    private static func preferredBashLoginFile() -> URL {
        let manager = FileManager.default
        return bashLoginCandidates.first(where: { manager.fileExists(atPath: $0.path) }) ?? bashProfileURL
    }
}

private struct InstalledSnapshot: Codable {
    let petNames: [String]
    let openerCount: Int
    let tint: String
    let effect: String
    let prompt: String
    let frequency: String
    let shells: [String]

    init(configuration: InstallConfiguration) {
        petNames = configuration.pets.map(\.name)
        openerCount = configuration.openers.count
        tint = configuration.tint.rawValue
        effect = configuration.customization.introEffect.rawValue
        prompt = configuration.customization.prompt.enabled
            ? configuration.customization.prompt.style.rawValue
            : "Off"
        frequency = configuration.customization.frequency.rawValue
        shells = [
            configuration.installZsh ? "zsh" : nil,
            configuration.installBash ? "bash" : nil
        ].compactMap { $0 }
    }
}
