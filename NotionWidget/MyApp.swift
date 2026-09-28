import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.styleMask = [.borderless, .resizable]
            window.setContentSize(NSSize(width: 500, height: 750))
            
            window.isOpaque = false
            window.backgroundColor = .clear

            window.level = .normal
//            window.ignoresMouseEvents = false
            
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let windowFrame = window.frame
                let margin: CGFloat = 16

                let x = screenFrame.maxX - windowFrame.width - margin
                let y = screenFrame.maxY - windowFrame.height - margin

                window.setFrameOrigin(NSPoint(x: x, y: y))
            }
        }
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
