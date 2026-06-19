//
//  MyBangumiTests.swift
//  MyBangumiTests
//
//  Created by 白依江 on 2026/6/20.
//

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
}
