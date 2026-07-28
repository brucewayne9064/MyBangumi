//
//  MyBangumiTests.swift
//  MyBangumiTests
//
//  Created by 白依江 on 2026/6/20.
//

import Foundation
import Testing
@testable import MyBangumi

struct MyBangumiTests {
    @Test func appLaunchConfigurationUsesRealAPIByDefault() {
        let configuration = AppLaunchConfiguration(arguments: [])

        #expect(configuration.usesMockAPI == false)
    }

    @Test func appLaunchConfigurationUsesMockAPIWhenFlagIsPresent() {
        let configuration = AppLaunchConfiguration(arguments: [AppLaunchConfiguration.useMockAPIFlag])

        #expect(configuration.usesMockAPI)
    }

    @Test func appLaunchConfigurationReadsOAuthCredentialsFromEnvironment() {
        let configuration = AppLaunchConfiguration(arguments: [], environment: [
            "BANGUMI_CLIENT_ID": "client-id",
            "BANGUMI_CLIENT_SECRET": "client-secret",
            "BANGUMI_REDIRECT_URI": "mybangumi://oauth/callback"
        ])

        #expect(configuration.oauthCredentials == BangumiOAuthCredentials(
            clientID: "client-id",
            clientSecret: "client-secret",
            redirectURI: URL(string: "mybangumi://oauth/callback")!
        ))
    }
}
