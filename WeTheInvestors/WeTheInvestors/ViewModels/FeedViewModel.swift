import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var items: [TradeItem] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var cursor: String? = nil
    @Published var filters: FeedFilters = .default
    @Published var scopeFollowedOnly = false

    private let api = APIClient()

    func initialLoad() async {
        if let cached: FeedResponse = await JSONDiskCache.shared.get("feed.json", as: FeedResponse.self) {
            self.items = cached.items
            self.cursor = cached.nextCursor
        }
        await refresh()
    }

    func refresh() async {
        isLoading = true; defer { isLoading = false }
        do {
            let data = try await api.getFeed(limit: AppConfig.defaultPageSize, cursor: nil, filters: filters)
            items = data.items
            cursor = data.nextCursor
            await JSONDiskCache.shared.set("feed.json", value: data)
        } catch {
            self.error = "Failed to load feed"
        }
    }

    func loadMore() async {
        guard let next = cursor, !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let data = try await api.getFeed(limit: AppConfig.defaultPageSize, cursor: next, filters: filters)
            items.append(contentsOf: data.items)
            cursor = data.nextCursor
        } catch { self.error = "Failed to load more" }
    }
}
