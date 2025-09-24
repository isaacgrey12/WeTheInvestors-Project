//
//  WeTheInvestorsApp.swift
//  WeTheInvestors
//
//  Created by Dhruv Chittamuri on 8/19/25.
//

import SwiftUI

@main
struct WeTheInvestorsApp: App {
    @StateObject private var followingStore = FollowingStore()
    @StateObject private var api = MockAPIClient()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(followingStore)
                .environmentObject(api)
        }
    }
}
