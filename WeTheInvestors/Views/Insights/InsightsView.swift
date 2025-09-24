import SwiftUI

struct InsightsView: View {
    private let api: any APIClient
    @StateObject private var vm: InsightsViewModel

    init(api: any APIClient) {
        self.api = api
        _vm = StateObject(wrappedValue: InsightsViewModel(api: api))
    }

    var body: some View {
        List {
            if let data = vm.data {
                Section("Trending Tickers") {
                    ForEach(data.trendingTickers) { item in
                        HStack {
                            Text(item.ticker).font(.headline)
                            Spacer()
                            Text("\(item.count)").foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Top Movers by Member") {
                    ForEach(data.topMoversByMember) { mover in
                        VStack(alignment: .leading) {
                            Text(mover.member.fullName).font(.headline)
                            Text("Trades: \(mover.tradeCount) • $\(Int(mover.totalDollars))")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Education") {
                    ForEach(data.education, id: \.self) { s in Text(s) }
                }
            } else if vm.isLoading {
                ProgressView("Loading…")
            } else {
                Text("No insights yet").foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Insights")
        .task { await vm.load() }   // just load; no reassignments
    }
}
