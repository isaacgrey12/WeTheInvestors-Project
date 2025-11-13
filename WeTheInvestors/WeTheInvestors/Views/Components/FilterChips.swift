import SwiftUI

struct FilterChips: View {
    @Binding var filters: FeedFilters

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack { chip("All"){ filters = .default }; chip("House"){ filters.chamber = "House" }; chip("Senate"){ filters.chamber = "Senate" } }
            HStack { chip("Buy"){ filters.txn = "Buy" }; chip("Sell"){ filters.txn = "Sell" }; chip("Other"){ filters.txn = "Other" } }
            HStack { chip("D"){ filters.party = "D" }; chip("R"){ filters.party = "R" }; chip("I"){ filters.party = "I" } }
        }
    }

    private func chip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).padding(.horizontal, 10).padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
    }
}
