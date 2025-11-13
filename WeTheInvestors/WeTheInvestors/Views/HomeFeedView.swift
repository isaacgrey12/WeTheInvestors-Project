import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var vm: FeedViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.items.isEmpty && vm.isLoading { ProgressView().padding() }
                else if vm.items.isEmpty { EmptyStateView(text: "No trades yet") }
                else { feedList }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $vm.scopeFollowedOnly) {
                        Text(vm.scopeFollowedOnly ? "Followed" : "All")
                    }.toggleStyle(.switch)
                }
            }
            .navigationTitle("Home Feed")
            .refreshable { await vm.refresh() }
        }
    }

    private var feedList: some View {
        List {
            ForEach(vm.items) { item in
                NavigationLink { MemberView(member: item.member) } label: {
                    TradeRow(item: item)
                }
            }
            if vm.cursor != nil {
                HStack { Spacer(); ProgressView().task { await vm.loadMore() }; Spacer() }
            }
        }
        .listStyle(.plain)
    }
}
