import Foundation

struct APIClient {
    private var base: URL { AppConfig.baseURL }
    private var session: URLSession { URLSession.shared }

    func getFeed(limit: Int = AppConfig.defaultPageSize, cursor: String? = nil, filters: FeedFilters = .init()) async throws -> FeedResponse {
        var comps = URLComponents(url: base.appendingPathComponent("/v1/feed"), resolvingAgainstBaseURL: false)!
        var items: [URLQueryItem] = [URLQueryItem(name: "limit", value: String(limit))]
        if let c = cursor { items.append(.init(name: "cursor", value: c)) }
        if let chamber = filters.chamber { items.append(.init(name: "chamber", value: chamber)) }
        if let party = filters.party { items.append(.init(name: "party", value: party)) }
        if let txn = filters.txn { items.append(.init(name: "txn", value: txn)) }
        if let start = filters.start { items.append(.init(name: "start", value: start)) }
        if let end = filters.end { items.append(.init(name: "end", value: end)) }
        if let ticker = filters.ticker { items.append(.init(name: "ticker", value: ticker)) }
        comps.queryItems = items
        var req = URLRequest(url: comps.url!)
        req.addValue(AppConfig.deviceId, forHTTPHeaderField: "x-device-id")
        let (data, resp) = try await session.data(for: req)
        try validate(resp)
        return try JSONDecoder().decode(FeedResponse.self, from: data)
    }

    func getMember(_ id: Int) async throws -> Member {
        let url = base.appendingPathComponent("/v1/members/\(id)")
        let (data, resp) = try await session.data(from: url)
        try validate(resp)
        return try JSONDecoder().decode(Member.self, from: data)
    }

    func getMemberTrades(_ id: Int, limit: Int = AppConfig.defaultPageSize, cursor: String? = nil) async throws -> FeedResponse {
        var comps = URLComponents(url: base.appendingPathComponent("/v1/members/\(id)/trades"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let c = cursor { comps.queryItems?.append(.init(name: "cursor", value: c)) }
        let (data, resp) = try await URLSession.shared.data(from: comps.url!)
        try validate(resp)
        return try JSONDecoder().decode(FeedResponse.self, from: data)
    }

    func getTickerTrades(_ symbol: String, limit: Int = AppConfig.defaultPageSize, cursor: String? = nil) async throws -> FeedResponse {
        var comps = URLComponents(url: base.appendingPathComponent("/v1/tickers/\(symbol)/trades"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        if let c = cursor { comps.queryItems?.append(.init(name: "cursor", value: c)) }
        let (data, resp) = try await URLSession.shared.data(from: comps.url!)
        try validate(resp)
        return try JSONDecoder().decode(FeedResponse.self, from: data)
    }

    func getTrending(window: Int = 7, limit: Int = 20) async throws -> [TrendingItem] {
        var comps = URLComponents(url: base.appendingPathComponent("/v1/insights/trending"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "window", value: String(window)), URLQueryItem(name: "limit", value: String(limit))]
        let (data, resp) = try await URLSession.shared.data(from: comps.url!)
        try validate(resp)
        return try JSONDecoder().decode([TrendingItem].self, from: data)
    }

    private func validate(_ resp: URLResponse) throws {
        if let h = resp as? HTTPURLResponse, (200..<300).contains(h.statusCode) { return }
        throw URLError(.badServerResponse)
    }
}
