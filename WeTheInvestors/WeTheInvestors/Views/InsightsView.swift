import SwiftUI

struct InsightsView: View {
    @StateObject private var vm = InsightsViewModel()

    var body: some View {
        NavigationStack {
            List(vm.trending) { item in
                HStack {
                    Text(item.symbol).font(.headline)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Trades: \(item.tradeCount)")
                        Text("Buy/Sell: \(item.buy)/\(item.sell)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Insights")
            .task { await vm.load() }
        }
    }
}

