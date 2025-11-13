import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var trending: [TrendingItem] = []
    @Published var isLoading = false
    private let api = APIClient()

    func load() async {
        isLoading = true; defer { isLoading = false }
        do { trending = try await api.getTrending() } catch { }
    }
}
