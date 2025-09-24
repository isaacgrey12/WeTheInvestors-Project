import SwiftUI

struct TradeRowView: View {
    let trade: Trade

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(trade.ticker)
                .font(.headline)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(trade.transaction == .purchase ? "Purchase" : "Sale")")
                    .font(.subheadline)
                    .foregroundStyle(trade.transaction == .purchase ? .green : .red)
                Text("\(trade.member.fullName) · \(trade.member.chamber.rawValue.capitalized) · \(trade.member.party.rawValue.uppercased())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("Traded: \(trade.dateTraded.formatted(date: .abbreviated, time: .omitted)) · Filed: \(trade.dateFiled.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("\(trade.assetType.rawValue.capitalized) · \(trade.estimatedAmountRange)")
                    .font(.footnote)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(trade.member.fullName) \(trade.transaction == .purchase ? "purchased" : "sold") \(trade.ticker), \(trade.estimatedAmountRange)")
    }
}
