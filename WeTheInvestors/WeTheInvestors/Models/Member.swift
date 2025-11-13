import Foundation

struct Member: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let chamber: String
    let party: String?
    let state: String?
    let district: String?
}
