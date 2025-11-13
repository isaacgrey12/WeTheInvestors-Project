import Foundation

actor JSONDiskCache {
    static let shared = JSONDiskCache()
    private let fm = FileManager.default
    private let dir: URL
    init() {
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        dir = base.appendingPathComponent("feed-cache", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }
    func get<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        let url = dir.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    func set<T: Encodable>(_ key: String, value: T) {
        let url = dir.appendingPathComponent(key)
        if let data = try? JSONEncoder().encode(value) {
            try? data.write(to: url)
        }
    }
}
