import SwiftUI

struct SearchView: View {
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    TextField("Search ticker or member", text: $vm.query)
                        .textFieldStyle(.roundedBorder)
                    Button("Go") { Task { await vm.runSearch() } }
                        .buttonStyle(.bordered)
                }
                FilterChips(filters: $vm.filters)
                List(vm.results) { item in
                    NavigationLink { MemberView(member: item.member) } label: {
                        TradeRow(item: item)
                    }
                }
            }
            .padding()
            .navigationTitle("Search & Filter")
        }
    }
}
