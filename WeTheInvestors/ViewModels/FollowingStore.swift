import Foundation

@MainActor
final class FollowingStore: ObservableObject {
    @Published private(set) var followed: Set<String> = Persistence.loadFollowed()

    func isFollowed(_ memberID: String) -> Bool { followed.contains(memberID) }

    func toggle(_ memberID: String) {
        if followed.contains(memberID) { followed.remove(memberID) }
        else { followed.insert(memberID) }
        Persistence.saveFollowed(followed)
    }
}
