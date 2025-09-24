import Foundation

struct TrendingTicker: Codable, Hashable, Identifiable {
    var id: String { ticker }
    let ticker: String
    let count: Int
}

struct MemberMover: Codable, Hashable, Identifiable {
    // You can choose a stable id (e.g., member.id + metric)
    var id: String { "\(member.id)-\(tradeCount)-\(Int(totalDollars))" }
    let member: Member
    let tradeCount: Int
    let totalDollars: Double
}

struct InsightsPayload: Codable {
    var trendingTickers: [TrendingTicker]
    var topMoversByMember: [MemberMover]
    var education: [String]  // keep simple for now
}
