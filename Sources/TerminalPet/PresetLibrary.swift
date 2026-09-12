import Foundation

struct TerminalPreset: Identifiable {
    let id: String
    let name: String
    let detail: String
    let symbol: String
    let tint: TerminalTint
    let settings: CustomizationSettings
}

enum PresetLibrary {
    static let presets: [TerminalPreset] = [
        TerminalPreset(
            id: "phosphor-classic",
            name: "Phosphor Classic",
            detail: "Green glow, a restrained scan, useful system facts.",
            symbol: "display",
            tint: .phosphor,
            settings: phosphorClassic()
        ),
        TerminalPreset(
            id: "neon-exorcism",
            name: "Neon Exorcism",
            detail: "Pink/cyan duotone with haunted flicker energy.",
            symbol: "wand.and.stars",
            tint: .hotPink,
            settings: neonExorcism()
        ),
        TerminalPreset(
            id: "amber-mainframe",
            name: "Amber Mainframe",
            detail: "1979 operator console, except the pet has opinions.",
            symbol: "memorychip",
            tint: .amber,
            settings: amberMainframe()
        ),
        TerminalPreset(
            id: "ice-station",
            name: "Ice Station",
            detail: "Cold, clean, information-dense, slightly ominous.",
            symbol: "snowflake",
            tint: .ice,
            settings: iceStation()
        ),
        TerminalPreset(
            id: "blood-moon",
            name: "Blood Moon",
            detail: "Crimson signal lock and a hard operator prompt.",
            symbol: "moon.stars.fill",
            tint: .crimson,
            settings: bloodMoon()
        ),
        TerminalPreset(
            id: "quiet-giant",
            name: "Quiet Giant",
            detail: "Violet, cyan, calm confidence, no unnecessary noise.",
            symbol: "waveform.path",
            tint: .violet,
            settings: quietGiant()
        ),
        TerminalPreset(
            id: "cotton-candy-root",
            name: "Cotton Candy Root",
            detail: "Cute colors. Unreasonable permissions.",
            symbol: "cloud.fill",
            tint: .hotPink,
            settings: cottonCandy()
        ),
        TerminalPreset(
            id: "chaos-engine",
            name: "Chaos Engine",
            detail: "Rainbow pet roulette with a boot sequence. Obviously.",
            symbol: "aqi.high",
            tint: .cyan,
            settings: chaosEngine()
        )
    ]

    private static func phosphorClassic() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .solid
        value.secondaryTint = .cyan
        value.metadataTint = .phosphor
        value.dividerStyle = .line
        value.introEffect = .lineReveal
        value.introSpeed = .fast
        value.showClock = true
        value.showUserHost = true
        value.showOS = true
        value.showArchitecture = true
        value.prompt.enabled = true
        value.prompt.style = .minimal
        value.prompt.primaryTint = .phosphor
        return value
    }

    private static func neonExorcism() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .duotone
        value.secondaryTint = .cyan
        value.openerTint = .hotPink
        value.metadataTint = .cyan
        value.dividerStyle = .sparks
        value.introEffect = .ghostFlicker
        value.showClock = true
        value.showDate = true
        value.showUserHost = true
        value.setWindowTitle = true
        value.prompt.enabled = true
        value.prompt.style = .twoLine
        value.prompt.primaryTint = .hotPink
        value.prompt.secondaryTint = .cyan
        value.prompt.errorReactions = true
        return value
    }

    private static func amberMainframe() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .solid
        value.secondaryTint = .orange
        value.openerTint = .amber
        value.metadataTint = .amber
        value.dividerStyle = .double
        value.introEffect = .bootSequence
        value.introSpeed = .fast
        value.showClock = true
        value.showDate = true
        value.showUserHost = true
        value.showOS = true
        value.showArchitecture = true
        value.showUptime = true
        value.prompt.enabled = true
        value.prompt.style = .operatorStyle
        value.prompt.primaryTint = .amber
        value.prompt.secondaryTint = .orange
        return value
    }

    private static func iceStation() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .duotone
        value.secondaryTint = .electricBlue
        value.metadataTint = .ice
        value.dividerStyle = .dots
        value.introEffect = .signalLock
        value.introSpeed = .fast
        value.showClock = true
        value.showDate = true
        value.showCWD = true
        value.showShell = true
        value.showBattery = true
        value.prompt.enabled = true
        value.prompt.style = .capsule
        value.prompt.primaryTint = .ice
        value.prompt.secondaryTint = .electricBlue
        value.prompt.showTime = true
        return value
    }

    private static func bloodMoon() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .duotone
        value.secondaryTint = .orange
        value.openerTint = .crimson
        value.metadataTint = .orange
        value.dividerStyle = .blocks
        value.introEffect = .signalLock
        value.showClock = true
        value.showUserHost = true
        value.showGitBranch = true
        value.prompt.enabled = true
        value.prompt.style = .operatorStyle
        value.prompt.primaryTint = .crimson
        value.prompt.secondaryTint = .orange
        value.prompt.errorReactions = true
        return value
    }

    private static func quietGiant() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .duotone
        value.secondaryTint = .cyan
        value.openerTint = .paper
        value.metadataTint = .violet
        value.dividerStyle = .dots
        value.introEffect = .lineReveal
        value.introSpeed = .normal
        value.showClock = true
        value.showCWD = true
        value.showBattery = true
        value.prompt.enabled = true
        value.prompt.style = .twoLine
        value.prompt.primaryTint = .violet
        value.prompt.secondaryTint = .cyan
        value.prompt.symbol = "◆"
        return value
    }

    private static func cottonCandy() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .duotone
        value.secondaryTint = .violet
        value.openerTint = .hotPink
        value.metadataTint = .ice
        value.dividerStyle = .sparks
        value.introEffect = .lineReveal
        value.showClock = true
        value.showDate = true
        value.prompt.enabled = true
        value.prompt.style = .capsule
        value.prompt.primaryTint = .hotPink
        value.prompt.secondaryTint = .violet
        return value
    }

    private static func chaosEngine() -> CustomizationSettings {
        var value = CustomizationSettings()
        value.petColorMode = .rainbow
        value.secondaryTint = .hotPink
        value.openerTint = .cyan
        value.metadataTint = .amber
        value.dividerStyle = .blocks
        value.introEffect = .bootSequence
        value.introSpeed = .fast
        value.showClock = true
        value.showUserHost = true
        value.showCWD = true
        value.showOS = true
        value.showArchitecture = true
        value.showShell = true
        value.showBattery = true
        value.showUptime = true
        value.showGitBranch = true
        value.setWindowTitle = true
        value.frequency = .coinFlip
        value.prompt.enabled = true
        value.prompt.style = .twoLine
        value.prompt.primaryTint = .cyan
        value.prompt.secondaryTint = .hotPink
        value.prompt.showTime = true
        value.prompt.errorReactions = true
        value.prompt.symbol = "⚡"
        return value
    }
}
