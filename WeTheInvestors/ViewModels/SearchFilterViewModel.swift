import Foundation

@MainActor
final class SearchFilterViewModel: ObservableObject {
    @Published var filter = FilterState()
    @Published var results: [Member] = []
    @Published var saved: [SavedFilter] = Persistence.loadSavedFilters()
    @Published var isSearching = false

    private let api: any APIClient

    init(api: any APIClient) { self.api = api }

    func search() async {
        isSearching = true
        defer { isSearching = false }
        do {
            results = try await api.searchMembers(query: filter.query, filter: filter)
        } catch {
            // TODO: error state
        }
    }

    func saveCurrentFilter(named name: String) {
        let item = SavedFilter(id: UUID(), name: name, filter: filter, createdAt: .now)
        saved.insert(item, at: 0)
        Persistence.saveSavedFilters(saved)
    }

    func loadSavedFilter(_ item: SavedFilter) {
        filter = item.filter
    }
}
