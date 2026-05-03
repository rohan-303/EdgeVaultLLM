import Foundation

final class Logger {
    static func info(_ message: String) { print("[EdgeVault][INFO] \(message)") }
    static func warning(_ message: String) { print("[EdgeVault][WARN] \(message)") }
    static func error(_ message: String) { print("[EdgeVault][ERROR] \(message)") }
}
