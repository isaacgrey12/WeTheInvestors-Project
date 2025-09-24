import SwiftUI

struct MemberRowView: View {
    let member: Member
    @EnvironmentObject private var following: FollowingStore

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(member.fullName).font(.headline)
                Text("\(member.chamber.rawValue.capitalized) · \(member.party.rawValue.uppercased()) · \(member.stateOrDistrict)")
                    .font(.footnote).foregroundStyle(.secondary)
                if let n = member.tradesLast30d {
                    Text("Trades (30d): \(n)").font(.footnote)
                }
            }
            Spacer()
            Button {
                following.toggle(member.id)
            } label: {
                Image(systemName: following.isFollowed(member.id) ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
                    .accessibilityLabel(following.isFollowed(member.id) ? "Unfollow" : "Follow")
            }
        }
    }
}
