import Foundation

@MainActor
final class MemberViewModel: ObservableObject {
    @Published var member: Member
    @Published var trades: [TradeItem] = []
    @Published var cursor: String? = nil
    @Published var isLoading = false
    private let api = APIClient()

    init(member: Member) { self.member = member }

    func load() async {
        isLoading = true; defer { isLoading = false }
        do {
            let resp = try await api.getMemberTrades(member.id)
            trades = resp.items
            cursor = resp.nextCursor
        } catch { }
    }

    func loadMore() async {
        guard let c = cursor, !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let resp = try await api.getMemberTrades(member.id, cursor: c)
            trades.append(contentsOf: resp.items)
            cursor = resp.nextCursor
        } catch { }
    }
}
