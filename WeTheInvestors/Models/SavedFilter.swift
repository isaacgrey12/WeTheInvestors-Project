import Foundation

struct SavedFilter: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var filter: FilterState
    var createdAt: Date
}
