import SwiftUI

struct SearchFilterView: View {
    private let api: any APIClient
    @StateObject private var vm: SearchFilterViewModel
    @EnvironmentObject private var following: FollowingStore

    @State private var savedName: String = ""

    init(api: any APIClient) {
        self.api = api
        _vm = StateObject(wrappedValue: SearchFilterViewModel(api: api))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Search
                Section(header: Text("Search")) {
                    TextField("Ticker, member, or state/district", text: $vm.filter.query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button {
                        Task { await vm.search() }
                    } label: {
                        if vm.isSearching { ProgressView() } else { Text("Search") }
                    }
                    .disabled(vm.isSearching)
                }

                // Filters
                Section(header: Text("Filters")) {
                    // Transaction
                    Picker("Transaction", selection: Binding(get: {
                        vm.filter.transaction
                    }, set: { vm.filter.transaction = $0 })) {
                        Text("Any").tag(nil as TransactionType?)
                        Text("Purchase").tag(TransactionType.purchase as TransactionType?)
                        Text("Sale").tag(TransactionType.sale as TransactionType?)
                    }

                    // Chamber
                    Picker("Chamber", selection: Binding(get: {
                        vm.filter.chamber
                    }, set: { vm.filter.chamber = $0 })) {
                        Text("Any").tag(nil as Chamber?)
                        Text("House").tag(Chamber.house as Chamber?)
                        Text("Senate").tag(Chamber.senate as Chamber?)
                    }

                    // Party
                    Picker("Party", selection: Binding(get: {
                        vm.filter.party
                    }, set: { vm.filter.party = $0 })) {
                        Text("All").tag(nil as Party?)
                        Text("D").tag(Party.d as Party?)
                        Text("R").tag(Party.r as Party?)
                        Text("I").tag(Party.i as Party?)
                    }

                    // Since days
                    Stepper(
                        "Since last \(vm.filter.sinceDays ?? 30) days",
                        value: Binding(
                            get: { vm.filter.sinceDays ?? 30 },
                            set: { vm.filter.sinceDays = $0 }
                        ),
                        in: 1...365
                    )
                }

                // Results
                Section(header: Text("Results")) {
                    if vm.results.isEmpty {
                        Text("No results yet. Try searching.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.results, id: \.id) { m in
                            MemberRowView(member: m)
                        }
                    }
                }

                // Saved Filters
                Section(header: Text("Saved Filters")) {
                    HStack {
                        TextField("Name (e.g. “Big Tech Buys”)", text: $savedName)
                            .textInputAutocapitalization(.words)
                        Button("Save") {
                            let name = savedName.trimmingCharacters(in: .whitespaces)
                            guard !name.isEmpty else { return }
                            vm.saveCurrentFilter(named: name)
                            savedName = ""
                        }
                    }

                    if vm.saved.isEmpty {
                        Text("No saved filters")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.saved, id: \.id) { item in
                            Button {
                                vm.loadSavedFilter(item)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name).font(.headline)
                                    Text(item.createdAt, style: .date)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search & Filter")
        }
    }
}
