import Foundation

struct Trade: Identifiable, Codable, Hashable {
    let id: String
    let ticker: String
    let transaction: TransactionType
    let member: Member
    let dateTraded: Date
    let dateFiled: Date
    let estimatedAmountRange: String  // e.g., "$1K–$15K"
    let assetType: AssetType
}
