import SwiftUI

struct TickerView: View {
    @StateObject private var vm: TickerViewModel
    init(symbol: String) { _vm = StateObject(wrappedValue: TickerViewModel(symbol: symbol)) }
    var body: some View {
        List {
            Section("Ticker") { Text(vm.symbol).font(.title2).bold() }
            Section("Trades") {
                ForEach(vm.trades) { TradeRow(item: $0) }
                if vm.cursor != nil {
                    HStack { Spacer(); ProgressView().task { await vm.loadMore() }; Spacer() }
                }
            }
        }
        .navigationTitle(vm.symbol)
        .task { await vm.load() }
    }
}
