import Foundation

@MainActor
final class TickerViewModel: ObservableObject {
    @Published var symbol: String
    @Published var trades: [TradeItem] = []
    @Published var cursor: String? = nil
    @Published var isLoading = false
    private let api = APIClient()

    init(symbol: String) { self.symbol = symbol }

    func load() async {
        isLoading = true; defer { isLoading = false }
        do {
            let resp = try await api.getTickerTrades(symbol)
            trades = resp.items
            cursor = resp.nextCursor
        } catch { }
    }

    func loadMore() async {
        guard let c = cursor, !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let resp = try await api.getTickerTrades(symbol, cursor: c)
            trades.append(contentsOf: resp.items)
            cursor = resp.nextCursor
        } catch { }
    }
}
