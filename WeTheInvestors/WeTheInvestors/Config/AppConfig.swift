import Foundation

enum AppConfig {
    #if targetEnvironment(simulator)
    static let baseURL = URL(string: "http://localhost:8080")!
    #else
    // If testing on device, use your Mac's LAN IP (e.g., http://192.168.1.123:8080)
    static let baseURL = URL(string: "http://localhost:8080")!
    #endif
    static let deviceId: String = Keychain.shared.getOrCreateDeviceId()
    static let defaultPageSize = 50
}
