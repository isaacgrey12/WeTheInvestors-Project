import SwiftUI

@main
struct WeTheInvestorsApp: App {
    @StateObject private var feedVM = FeedViewModel()
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(feedVM)
                .task { await feedVM.initialLoad() }
        }
    }
}
