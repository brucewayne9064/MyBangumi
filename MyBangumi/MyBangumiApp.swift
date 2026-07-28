//
//  MyBangumiApp.swift
//  MyBangumi
//
//  Created by 白依江 on 2026/6/20.
//

import Foundation
import SwiftUI

struct AppLaunchConfiguration {
    static let useMockAPIFlag = "-useMockAPI"

    let arguments: [String]

    var usesMockAPI: Bool {
        arguments.contains(Self.useMockAPIFlag)
    }

    func makeAPI(accessTokenProvider: (@Sendable () -> String?)? = nil) -> any BangumiAPI {
        usesMockAPI ? MockBangumiAPI() : BangumiAPIClient(accessTokenProvider: accessTokenProvider)
    }

    static var current: Self {
        Self(arguments: ProcessInfo.processInfo.arguments)
    }
}

@main
struct MyBangumiApp: App {
    private let launchConfiguration = AppLaunchConfiguration.current
    @State private var appSession = AppSession()

    var body: some Scene {
        WindowGroup {
            ContentView(
                api: launchConfiguration.makeAPI(accessTokenProvider: { appSession.accessToken }),
                appSession: appSession
            )
            .task {
                await appSession.restore()
            }
        }
    }
}
