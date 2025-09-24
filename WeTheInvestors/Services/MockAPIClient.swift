import Foundation

@MainActor
final class MockAPIClient: APIClient {
    @Published private(set) var lastUpdated: Date = .now

    func fetchTrades(filter: FilterState?, followedOnly: Bool) async throws -> [Trade] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return DemoData.trades
    }

    func searchMembers(query: String, filter: FilterState?) async throws -> [Member] {
        try await Task.sleep(nanoseconds: 150_000_000)
        let q = query.lowercased()
        return DemoData.members.filter {
            q.isEmpty || $0.fullName.lowercased().contains(q)
            || $0.stateOrDistrict.lowercased().contains(q)
        }
    }

    func fetchInsights() async throws -> InsightsPayload {
        try await Task.sleep(nanoseconds: 100_000_000)
        return InsightsPayload(
            trendingTickers: [
                TrendingTicker(ticker: "NVDA", count: 28),
                TrendingTicker(ticker: "AAPL", count: 22),
                TrendingTicker(ticker: "TSLA", count: 15),
            ],
            topMoversByMember: [
                MemberMover(member: DemoData.members[0], tradeCount: 7, totalDollars: 120_000),
                MemberMover(member: DemoData.members[1], tradeCount: 11, totalDollars: 350_000),
            ],
            education: ["How to read disclosures", "STOCK Act basics"]
        )
    }
}


enum DemoData {
    static let members: [Member] = [
        .init(id: "m1", fullName: "Jane Doe", chamber: .house, party: .d, stateOrDistrict: "CA-12", tradesLast30d: 7),
        .init(id: "m2", fullName: "John Roe", chamber: .senate, party: .r, stateOrDistrict: "TX", tradesLast30d: 11)
    ]

    static let trades: [Trade] = [
        .init(id: "t1", ticker: "NVDA", transaction: .purchase, member: members[0],
              dateTraded: Date().addingTimeInterval(-86400*2),
              dateFiled: Date().addingTimeInterval(-86400),
              estimatedAmountRange: "$1K–$15K", assetType: .stock),
        .init(id: "t2", ticker: "AAPL", transaction: .sale, member: members[1],
              dateTraded: Date().addingTimeInterval(-86400*5),
              dateFiled: Date().addingTimeInterval(-86400*3),
              estimatedAmountRange: "$50K+", assetType: .stock)
    ]
}
