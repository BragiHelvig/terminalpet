import Foundation
import SwiftUI

struct TerminalPet: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var art: String
    var isCustom: Bool
}

enum OpenerMood: String, Codable, CaseIterable, Identifiable {
    case dry = "Dry wit"
    case chaotic = "Chaotic"
    case hype = "Hype"
    case cozy = "Cozy"
    case machine = "Machine spirit"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .dry: return "quote.bubble"
        case .chaotic: return "sparkles"
        case .hype: return "bolt.fill"
        case .cozy: return "mug.fill"
        case .machine: return "cpu"
        }
    }
}

struct TerminalOpener: Identifiable, Codable, Hashable {
    let id: String
    var text: String
    var mood: OpenerMood
    var isCustom: Bool
}

enum TerminalTint: String, Codable, CaseIterable, Identifiable {
    case phosphor, cyan, electricBlue, hotPink, crimson, orange, amber, violet, ice, paper
    var id: String { rawValue }

    var title: String {
        switch self {
        case .phosphor: return "Phosphor"
        case .cyan: return "Cyan"
        case .electricBlue: return "Electric blue"
        case .hotPink: return "Hot pink"
        case .crimson: return "Crimson"
        case .orange: return "Orange"
        case .amber: return "Amber"
        case .violet: return "Violet"
        case .ice: return "Ice"
        case .paper: return "Paper"
        }
    }

    var color: Color {
        switch self {
        case .phosphor: return Color(red: 0.45, green: 1.0, blue: 0.55)
        case .cyan: return Color(red: 0.32, green: 0.91, blue: 1.0)
        case .electricBlue: return Color(red: 0.30, green: 0.55, blue: 1.0)
        case .hotPink: return Color(red: 1.0, green: 0.36, blue: 0.72)
        case .crimson: return Color(red: 1.0, green: 0.30, blue: 0.36)
        case .orange: return Color(red: 1.0, green: 0.48, blue: 0.20)
        case .amber: return Color(red: 1.0, green: 0.72, blue: 0.28)
        case .violet: return Color(red: 0.72, green: 0.52, blue: 1.0)
        case .ice: return Color(red: 0.72, green: 0.86, blue: 1.0)
        case .paper: return Color(red: 0.92, green: 0.92, blue: 0.92)
        }
    }

    var ansiCode: Int {
        switch self {
        case .phosphor: return 119
        case .cyan: return 45
        case .electricBlue: return 75
        case .hotPink: return 213
        case .crimson: return 203
        case .orange: return 209
        case .amber: return 215
        case .violet: return 141
        case .ice: return 153
        case .paper: return 255
        }
    }
}

enum PetSelectionMode: String, Codable, CaseIterable, Identifiable {
    case fixed = "Chosen pet"
    case rotation = "Pet roulette"
    var id: String { rawValue }
}

enum PetColorMode: String, Codable, CaseIterable, Identifiable {
    case solid = "Solid"
    case duotone = "Duotone"
    case rainbow = "Rainbow"
    var id: String { rawValue }
}

enum DividerStyle: String, Codable, CaseIterable, Identifiable {
    case line = "Quiet line"
    case double = "Double rail"
    case dots = "Signal dots"
    case sparks = "Star field"
    case blocks = "Data blocks"
    case none = "None"
    var id: String { rawValue }

    var glyphs: String {
        switch self {
        case .line: return "────────────────────────────────────"
        case .double: return "════════════════════════════════════"
        case .dots: return "· · · · · · · · · · · · · · · · · ·"
        case .sparks: return "✦  ·  ✧  ·  ✦  ·  ✧  ·  ✦  ·  ✧"
        case .blocks: return "▰▱▰▱▰▱▰▱▰▱▰▱▰▱▰▱▰▱"
        case .none: return ""
        }
    }
}

enum IntroEffect: String, Codable, CaseIterable, Identifiable {
    case instant = "Instant"
    case lineReveal = "Line reveal"
    case ghostFlicker = "Ghost flicker"
    case bootSequence = "Boot sequence"
    case signalLock = "Signal lock"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .instant: return "bolt"
        case .lineReveal: return "text.line.first.and.arrowtriangle.forward"
        case .ghostFlicker: return "sparkles"
        case .bootSequence: return "power"
        case .signalLock: return "wave.3.right"
        }
    }
}

enum IntroSpeed: String, Codable, CaseIterable, Identifiable {
    case fast = "Fast"
    case normal = "Normal"
    case cinematic = "Cinematic"
    var id: String { rawValue }

    var delay: String {
        switch self {
        case .fast: return "0.015"
        case .normal: return "0.045"
        case .cinematic: return "0.095"
        }
    }
}

enum DisplayFrequency: String, Codable, CaseIterable, Identifiable {
    case everyShell = "Every new shell"
    case oncePerTerminal = "Once per Terminal session"
    case oncePerDay = "Once per day"
    case coinFlip = "50% chaos"
    var id: String { rawValue }
}

enum SessionScope: String, Codable, CaseIterable, Identifiable {
    case everywhere = "Local + SSH"
    case localOnly = "Local only"
    case sshOnly = "SSH only"
    var id: String { rawValue }
}

enum PromptStyle: String, Codable, CaseIterable, Identifiable {
    case minimal = "Minimal"
    case twoLine = "Two-line"
    case capsule = "Capsule"
    case operatorStyle = "Operator"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .minimal: return "chevron.right"
        case .twoLine: return "text.alignleft"
        case .capsule: return "capsule"
        case .operatorStyle: return "command"
        }
    }
}

struct PromptSettings: Codable, Equatable {
    var enabled = false
    var style: PromptStyle = .twoLine
    var primaryTint: TerminalTint = .phosphor
    var secondaryTint: TerminalTint = .cyan
    var showTime = false
    var showUserHost = true
    var showCWD = true
    var showGitBranch = true
    var showExitStatus = true
    var errorReactions = false
    var symbol = "❯"
}

struct CustomizationSettings: Codable, Equatable {
    var petColorMode: PetColorMode = .solid
    var secondaryTint: TerminalTint = .cyan
    var openerTint: TerminalTint = .paper
    var metadataTint: TerminalTint = .ice
    var dividerStyle: DividerStyle = .line
    var introEffect: IntroEffect = .instant
    var introSpeed: IntroSpeed = .normal

    var showClock = true
    var showDate = false
    var showUserHost = false
    var showCWD = false
    var showOS = false
    var showArchitecture = false
    var showShell = false
    var showBattery = false
    var showUptime = false
    var showGitBranch = false

    var setWindowTitle = false
    var windowTitle = "{pet} · {cwd}"
    var terminalBell = false
    var frequency: DisplayFrequency = .everyShell
    var sessionScope: SessionScope = .everywhere
    var skipIDETerminals = false
    var respectNoColor = true
    var quietHoursEnabled = false
    var quietStart = 23
    var quietEnd = 7

    var prompt = PromptSettings()
}

enum AppSection: String, CaseIterable, Identifiable {
    case petStudio = "Pet Studio"
    case sceneBuilder = "Scene Builder"
    case openers = "Openers"
    case promptLab = "Prompt Lab"
    case setup = "Install & Share"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .petStudio: return "pawprint.fill"
        case .sceneBuilder: return "slider.horizontal.3"
        case .openers: return "text.quote"
        case .promptLab: return "chevron.left.forwardslash.chevron.right"
        case .setup: return "terminal.fill"
        }
    }
}

struct StoredSettings: Codable {
    var selectedPetID: String
    var customPets: [TerminalPet]
    var enabledOpenerIDs: [String]
    var customOpeners: [TerminalOpener]
    var tint: TerminalTint
    var showPetName: Bool
    var showDivider: Bool
    var installZsh: Bool
    var installBash: Bool
    var petSelectionMode: PetSelectionMode?
    var enabledPetIDs: [String]?
    var customization: CustomizationSettings?
}

struct ShareableConfiguration: Codable {
    let formatVersion: Int
    let exportedAt: Date
    let settings: StoredSettings
}

struct InstallConfiguration {
    let pets: [TerminalPet]
    let openers: [TerminalOpener]
    let tint: TerminalTint
    let showPetName: Bool
    let customization: CustomizationSettings
    let installZsh: Bool
    let installBash: Bool
}

enum InstallState: Equatable {
    case checking
    case notInstalled
    case installed(shells: [String])
    case error(String)

    var isInstalled: Bool {
        if case .installed = self { return true }
        return false
    }
}
