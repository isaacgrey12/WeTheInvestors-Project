import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            HomeFeedView()
                .tabItem { Label("Home", systemImage: "list.bullet.rectangle") }
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
        }
    }
}
