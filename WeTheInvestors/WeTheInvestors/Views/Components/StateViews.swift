import SwiftUI

struct EmptyStateView: View {
    var text: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }.padding(.vertical, 40)
    }
}
