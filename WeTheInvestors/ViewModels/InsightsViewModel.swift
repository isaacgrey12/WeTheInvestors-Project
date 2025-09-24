import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var data: InsightsPayload?
    @Published var isLoading = false

    private let api: any APIClient
    init(api: any APIClient) { self.api = api }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do { data = try await api.fetchInsights() } catch { /* handle */ }
    }
}
