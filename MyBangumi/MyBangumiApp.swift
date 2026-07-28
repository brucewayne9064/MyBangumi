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
    static let clientIDKey = "BANGUMI_CLIENT_ID"
    static let clientSecretKey = "BANGUMI_CLIENT_SECRET"
    static let redirectURIKey = "BANGUMI_REDIRECT_URI"

    let arguments: [String]
    let environment: [String: String]

    init(arguments: [String], environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.arguments = arguments
        self.environment = environment
    }

    var usesMockAPI: Bool {
        arguments.contains(Self.useMockAPIFlag)
    }

    var oauthCredentials: BangumiOAuthCredentials? {
        guard
            let clientID = environment[Self.clientIDKey], clientID.isEmpty == false,
            let clientSecret = environment[Self.clientSecretKey], clientSecret.isEmpty == false,
            let redirectURIString = environment[Self.redirectURIKey],
            let redirectURI = URL(string: redirectURIString)
        else {
            return nil
        }
        return BangumiOAuthCredentials(clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
    }

    func makeAPI(accessTokenProvider: (@Sendable () -> String?)? = nil) -> any BangumiAPI {
        usesMockAPI ? MockBangumiAPI() : BangumiAPIClient(accessTokenProvider: accessTokenProvider)
    }

    @MainActor
    func makeOAuthSignInHandler() -> OAuthSignInHandler? {
        guard let oauthCredentials else { return nil }
        let service = BangumiOAuthSignInService(credentials: oauthCredentials)
        return {
            try await service.signIn()
        }
    }

    static var current: Self {
        Self(arguments: ProcessInfo.processInfo.arguments, environment: ProcessInfo.processInfo.environment)
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
                appSession: appSession,
                oauthSignInHandler: launchConfiguration.makeOAuthSignInHandler()
            )
            .task {
                await appSession.restore()
            }
        }
    }
}
