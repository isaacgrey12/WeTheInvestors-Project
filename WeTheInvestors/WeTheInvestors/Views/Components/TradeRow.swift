import SwiftUI

struct TradeRow: View {
    let item: TradeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.ticker ?? "—").font(.headline)
                Capsule().frame(width: 6, height: 6).foregroundStyle(color).accessibilityLabel(item.txn)
                Text(item.txn).font(.subheadline).foregroundStyle(color)
                Spacer()
                Text(item.dateTraded ?? "").font(.subheadline)
            }
            Text(item.member.name + " • " + item.member.chamber + (partyText))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                if let amt = amountText { Label(amt, systemImage: "dollarsign.circle") }
                if let asset = item.assetType { Label(asset, systemImage: "shippingbox") }
                if let filed = item.dateFiled { Label("Filed: \(filed)", systemImage: "calendar") }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var color: Color {
        switch item.txn { case "Buy": return .green; case "Sell": return .red; default: return .gray }
    }
    private var partyText: String { item.member.party.map { " • \($0)" } ?? "" }
    private var amountText: String? {
        if let a = item.amount {
            let nums = [a.min, a.max].compactMap { $0 }.map { String(Int($0)) }.joined(separator: "-")
            return nums.isEmpty ? nil : "$" + nums
        }
        return nil
    }
}
