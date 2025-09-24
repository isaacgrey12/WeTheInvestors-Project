import Foundation

@MainActor
protocol APIClient: ObservableObject {
    func fetchTrades(filter: FilterState?, followedOnly: Bool) async throws -> [Trade]
    func searchMembers(query: String, filter: FilterState?) async throws -> [Member]
    func fetchInsights() async throws -> InsightsPayload
}
