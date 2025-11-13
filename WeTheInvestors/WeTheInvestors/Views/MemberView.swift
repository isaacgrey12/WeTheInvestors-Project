import SwiftUI

struct MemberView: View {
    @StateObject private var vm: MemberViewModel

    init(member: Member) {
        _vm = StateObject(wrappedValue: MemberViewModel(member: member))
    }

    var body: some View {
        List {
            Section("Member") {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.member.name).font(.headline)
                    Text("\(vm.member.chamber) • \(vm.member.party ?? "?") • \(vm.member.state ?? "")\(vm.member.district.map { "-\($0)" } ?? "")")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Section("Trades") {
                ForEach(vm.trades) { TradeRow(item: $0) }
                if vm.cursor != nil {
                    HStack { Spacer(); ProgressView().task { await vm.loadMore() }; Spacer() }
                }
            }
        }
        .navigationTitle("Member")
        .task { await vm.load() }
    }
}
