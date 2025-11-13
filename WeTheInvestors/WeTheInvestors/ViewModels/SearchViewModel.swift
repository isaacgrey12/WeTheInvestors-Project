import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var filters = FeedFilters()
    @Published var results: [TradeItem] = []
    @Published var cursor: String? = nil
    @Published var isLoading = false
    private let api = APIClient()

    func runSearch() async {
        isLoading = true; defer { isLoading = false }
        var f = filters
        if !query.isEmpty { f.ticker = query.uppercased() }
        do {
            let resp = try await api.getFeed(limit: AppConfig.defaultPageSize, cursor: nil, filters: f)
            results = resp.items
            cursor = resp.nextCursor
        } catch { }
    }
}
