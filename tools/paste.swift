// Paste the prepared clipboard into the focused iPhone field. iPhone Mirroring
// needs the Command key's own down/up events as well as the modifier flags.
import AppKit

func fail(_ reason: String) -> Never {
    FileHandle.standardError.write(Data((reason + "\n").utf8))
    exit(1)
}
guard let mirror = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.ScreenContinuity").first else {
    fail("iPhone Mirroring is not running")
}
let pid = mirror.processIdentifier
mirror.activate()
let app = AXUIElementCreateApplication(pid)
var mainWindow: CFTypeRef?
if AXUIElementCopyAttributeValue(app, kAXMainWindowAttribute as CFString, &mainWindow) == .success,
   let mainWindow, CFGetTypeID(mainWindow) == AXUIElementGetTypeID() {
    AXUIElementPerformAction(mainWindow as! AXUIElement, kAXRaiseAction as CFString)
}
Thread.sleep(forTimeInterval: 0.25)

func checkFront() {
    guard NSWorkspace.shared.frontmostApplication?.processIdentifier == pid,
          let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]],
          let index = windows.firstIndex(where: { $0[kCGWindowOwnerPID as String] as? pid_t == pid && $0[kCGWindowLayer as String] as? Int == 0 }),
          let bounds = windows[index][kCGWindowBounds as String] as? [String: CGFloat],
          let frame = CGRect(dictionaryRepresentation: bounds as CFDictionary) else {
        fail("iPhone Mirroring is not in front")
    }
    for window in windows[..<index] where window[kCGWindowOwnerPID as String] as? pid_t != pid {
        // Compare application windows in front-to-back order. The system also
        // lists the cursor and transparent capture surfaces above every window.
        guard window[kCGWindowLayer as String] as? Int == 0,
              let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
              let other = CGRect(dictionaryRepresentation: bounds as CFDictionary) else { continue }
        if other.intersects(frame) && (window[kCGWindowAlpha as String] as? Double ?? 1) > 0 {
            fail("another window covers iPhone Mirroring: " + (window[kCGWindowOwnerName as String] as? String ?? "unknown"))
        }
    }
}
func stroke(_ key: CGKeyCode, command: Bool = false) {
    checkFront()
    func post(_ code: CGKeyCode, down: Bool) {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down) else { fail("keyboard input unavailable") }
        event.flags = command ? .maskCommand : []
        event.post(tap: .cghidEventTap)
        Thread.sleep(forTimeInterval: 0.04)
    }
    if command { post(55, down: true) }
    post(key, down: true)
    post(key, down: false)
    if command { post(55, down: false) }
}
checkFront()
let args = Array(CommandLine.arguments.dropFirst())
switch args.first {
case "--front":
    // mirroir 0.50.3 treats the macOS cursor surface at the next tap point
    // as an occluding window. Park the pointer before starting its click route.
    if let display = NSScreen.main {
        let screen = display.frame
        CGWarpMouseCursorPosition(CGPoint(x: screen.maxX - 2, y: screen.midY))
    }
case "--text":
    guard args.count == 2 else { fail("expected a message") }
    stroke(0, command: true)
    stroke(51)
    let board = NSPasteboard.general
    board.clearContents()
    guard board.setString(args[1], forType: .string) else { fail("could not prepare text") }
    Thread.sleep(forTimeInterval: 0.4)
    stroke(9, command: true)
case "--image":
    guard NSPasteboard.general.canReadObject(forClasses: [NSImage.self], options: nil) else { fail("clipboard image missing") }
    stroke(9, command: true)
default: fail("usage: paste --front | --text <text> | --image")
}
