import Foundation

enum PetLibrary {
    static let pets: [TerminalPet] = [
        TerminalPet(
            id: "kernel-cat",
            name: "Kernel",
            art: #"""
             /\_/\
            ( o.o )
             > ^ <
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "sudo-dog",
            name: "sudo",
            art: #"""
             / \__
            (    @\___
             /         O
            /   (_____/
            /_____/   U
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "segfault-ghost",
            name: "Segfault",
            art: #"""
              .-.
             (o o)
             | O \
              \   \
               `~~~'
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "byte-duck",
            name: "Byte",
            art: #"""
               __
            <(o )___
             ( ._> /
              `---'
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "mobius-worm",
            name: "Möbius",
            art: #"""
               __      _
             _/  \____/ \
            /            \
            \__/\__/\___/
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "root-robot",
            name: "Rooty",
            art: #"""
             .--------.
             | 0    0 |
             |   __   |
             '---||---'
                /  \
            """#,
            isCustom: false
        ),
        TerminalPet(
            id: "daemon-bat",
            name: "Daemon",
            art: #"""
              /\                 /\
             / \'._   (\_/)   _.'/ \
            /_.''._'--('.')--'_.''._\
            | \_ / `;=/ " \=;` \ _/ |
             \/ `\__|`\___/`|__/` \/
            """#,
            isCustom: false
        )
    ]

    static let openers: [TerminalOpener] = [
        TerminalOpener(id: "dry-01", text: "No errors yet. Suspicious.", mood: .dry, isCustom: false),
        TerminalOpener(id: "dry-02", text: "Your pet inspected the PATH. It has concerns.", mood: .dry, isCustom: false),
        TerminalOpener(id: "dry-03", text: "Production is just staging with consequences.", mood: .dry, isCustom: false),
        TerminalOpener(id: "dry-04", text: "The cursor is blinking judgmentally.", mood: .dry, isCustom: false),
        TerminalOpener(id: "dry-05", text: "A clean git status would be nice someday.", mood: .dry, isCustom: false),

        TerminalOpener(id: "chaos-01", text: "Ship it before courage catches up.", mood: .chaotic, isCustom: false),
        TerminalOpener(id: "chaos-02", text: "Today we find out what that flag does.", mood: .chaotic, isCustom: false),
        TerminalOpener(id: "chaos-03", text: "The vibes are compiled. The warnings are decorative.", mood: .chaotic, isCustom: false),
        TerminalOpener(id: "chaos-04", text: "Tiny creature. Enormous permissions.", mood: .chaotic, isCustom: false),
        TerminalOpener(id: "chaos-05", text: "Your pet has chosen violence against one specific semicolon.", mood: .chaotic, isCustom: false),

        TerminalOpener(id: "hype-01", text: "Wake up, giant. Make the machine sing.", mood: .hype, isCustom: false),
        TerminalOpener(id: "hype-02", text: "Pet loaded. Impostor syndrome unloaded.", mood: .hype, isCustom: false),
        TerminalOpener(id: "hype-03", text: "One clean commit can change the whole day.", mood: .hype, isCustom: false),
        TerminalOpener(id: "hype-04", text: "You have a keyboard and a frankly unreasonable amount of potential.", mood: .hype, isCustom: false),
        TerminalOpener(id: "hype-05", text: "Build the weird thing.", mood: .hype, isCustom: false),

        TerminalOpener(id: "cozy-01", text: "Hydrate first. Then destabilize the industry.", mood: .cozy, isCustom: false),
        TerminalOpener(id: "cozy-02", text: "Slow is smooth. Smooth is deployable.", mood: .cozy, isCustom: false),
        TerminalOpener(id: "cozy-03", text: "The terminal is warm and your pet saved you a seat.", mood: .cozy, isCustom: false),
        TerminalOpener(id: "cozy-04", text: "Breathe in. Type something beautiful.", mood: .cozy, isCustom: false),
        TerminalOpener(id: "cozy-05", text: "Small steps still count as runtime.", mood: .cozy, isCustom: false),

        TerminalOpener(id: "machine-01", text: "The machine spirit accepts your offering.", mood: .machine, isCustom: false),
        TerminalOpener(id: "machine-02", text: "Silicon dreams. Carbon debugs.", mood: .machine, isCustom: false),
        TerminalOpener(id: "machine-03", text: "The daemon stirs beneath {host}.", mood: .machine, isCustom: false),
        TerminalOpener(id: "machine-04", text: "Welcome back, {user}. {pet} kept the process alive.", mood: .machine, isCustom: false),
        TerminalOpener(id: "machine-05", text: "Current lair: {cwd}", mood: .machine, isCustom: false)
    ]
}
