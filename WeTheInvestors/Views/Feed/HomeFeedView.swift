import SwiftUI

struct HomeFeedView: View {
    private let api: any APIClient
    private let following: FollowingStore
    @StateObject private var vm: FeedViewModel

    init(api: any APIClient, following: FollowingStore) {
        self.api = api
        self.following = following
        _vm = StateObject(wrappedValue: FeedViewModel(api: api, following: following))
    }

    var body: some View {
        VStack {
            Picker("", selection: $vm.showFollowedOnly) {
                Text("All Members").tag(false)
                Text("Followed").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            List(vm.trades) { trade in
                TradeRowView(trade: trade)
            }
            .listStyle(.plain)
            .refreshable { await vm.load() }
        }
        .navigationTitle("Home Feed")
        .task { await vm.load() }   // load only
    }
}
