import Foundation

struct FilterState: Codable, Equatable {
    var query: String = ""                   // ticker | member | state/district
    var transaction: TransactionType? = nil
    var chamber: Chamber? = nil
    var party: Party? = nil
    var sinceDays: Int? = 30                 // presets: 7, 30, 365 (YTD)
    var minAmount: Int? = nil                // dollars; bucketed in UI
    var sector: String? = nil
    var assetType: AssetType? = nil
}
