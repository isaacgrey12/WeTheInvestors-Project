import Foundation

struct FeedFilters: Codable, Equatable {
    var chamber: String? = nil   // House|Senate
    var party: String? = nil     // D|R|I
    var txn: String? = nil       // Buy|Sell|Other
    var start: String? = nil     // YYYY-MM-DD
    var end: String? = nil
    var ticker: String? = nil

    static let `default` = FeedFilters()
}
