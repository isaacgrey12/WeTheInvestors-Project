import Foundation

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var trades: [Trade] = []
    @Published var showFollowedOnly: Bool = false
    @Published var isLoading = false
    @Published var lastRefresh: Date?

    private let api: any APIClient
    private let following: FollowingStore
    private var refreshTask: Task<Void, Never>?

    init(api: any APIClient, following: FollowingStore) {
        self.api = api
        self.following = following
        startAutoRefresh() // periodic refresh per spec
    }

    deinit { refreshTask?.cancel() }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await api.fetchTrades(filter: nil, followedOnly: showFollowedOnly)
            trades = showFollowedOnly
                ? result.filter { following.isFollowed($0.member.id) }
                : result
            lastRefresh = Date()
        } catch {
            // TODO: expose error state
        }
    }

    private func startAutoRefresh() {
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 600_000_000_00) // ~10 minutes
                await self.load()
            }
        }
    }
}
