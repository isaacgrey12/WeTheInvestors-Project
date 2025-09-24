import Foundation

struct Persistence {
    static let followedKey = "followedMemberIDs"
    static let savedFiltersKey = "savedFilters"

    static func loadFollowed() -> Set<String> {
        let arr = UserDefaults.standard.stringArray(forKey: followedKey) ?? []
        return Set(arr)
    }

    static func saveFollowed(_ set: Set<String>) {
        UserDefaults.standard.set(Array(set), forKey: followedKey)
    }

    static func loadSavedFilters() -> [SavedFilter] {
        guard let data = UserDefaults.standard.data(forKey: savedFiltersKey) else { return [] }
        return (try? JSONDecoder().decode([SavedFilter].self, from: data)) ?? []
    }

    static func saveSavedFilters(_ items: [SavedFilter]) {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: savedFiltersKey)
    }
}
