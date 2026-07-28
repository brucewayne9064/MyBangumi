import Foundation

enum CommunityDataSource: Equatable, Sendable {
    case bangumiCollections
    case bangumiRatings
    case publicSubjectRanking
    case customBackend
}

struct CommunityStrategy: Equatable, Sendable {
    let title: String
    let dataSources: [CommunityDataSource]
    let requiresCustomBackend: Bool
    let risk: String
}

enum CommunityRoadmap {
    static let recommendationStrategy = CommunityStrategy(
        title: "轻量推荐",
        dataSources: [.bangumiCollections, .bangumiRatings, .publicSubjectRanking],
        requiresCustomBackend: false,
        risk: "第一版只基于本地记录和 Bangumi 公开数据，避免过早建设推荐服务。"
    )

    static let discussionStrategy = CommunityStrategy(
        title: "讨论板块",
        dataSources: [.customBackend],
        requiresCustomBackend: true,
        risk: "Bangumi 公开 API 对讨论能力有限；若自建讨论区，需要单独设计内容审核、举报、账号绑定和运营规则。"
    )
}
