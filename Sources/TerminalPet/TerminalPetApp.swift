import SwiftUI

@main
struct TerminalPetApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .preferredColorScheme(.dark)
                .frame(minWidth: 1180, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("Terminal Pet") {
                Button("Pet Studio") { model.section = .petStudio }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Scene Builder") { model.section = .sceneBuilder }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Openers") { model.section = .openers }
                    .keyboardShortcut("3", modifiers: .command)
                Button("Prompt Lab") { model.section = .promptLab }
                    .keyboardShortcut("4", modifiers: .command)
                Button("Install & Share") { model.section = .setup }
                    .keyboardShortcut("5", modifiers: .command)
            }
        }
    }
}
