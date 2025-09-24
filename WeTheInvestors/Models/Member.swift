import Foundation

struct Member: Identifiable, Codable, Hashable {
    let id: String                  // e.g., clerk/senate id or synthetic
    let fullName: String
    let chamber: Chamber
    let party: Party
    let stateOrDistrict: String
    var tradesLast30d: Int?
}
