import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var api: MockAPIClient
    @EnvironmentObject private var following: FollowingStore

    var body: some View {
        TabView {
            SearchFilterView(api: api)
                .environmentObject(following)
                .tabItem { Label("Search & Filter", systemImage: "magnifyingglass") }

            HomeFeedView(api: api, following: following)
                .tabItem { Label("Home", systemImage: "house") }

            InsightsView(api: api)
                .tabItem { Label("Insights", systemImage: "chart.bar") }
        }
    }
}
