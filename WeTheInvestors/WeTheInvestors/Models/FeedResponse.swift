import Foundation

struct FeedResponse: Codable {
    var items: [TradeItem]
    var nextCursor: String?
}

struct TradeItem: Codable, Identifiable {
    let id: Int
    let ticker: String?
    let company: String?
    let txn: String
    let member: Member
    let dateTraded: String?
    let dateFiled: String?
    let amount: Amount?
    let assetType: String?

    struct Amount: Codable { let min: Double?; let max: Double? }
}

struct TrendingItem: Codable, Identifiable { let id = UUID(); let symbol: String; let tradeCount: Int; let buy: Int; let sell: Int }
