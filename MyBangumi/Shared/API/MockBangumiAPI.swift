import Foundation

struct MockBangumiAPI: BangumiAPI {
    var currentUser: BangumiUser
    var airingCalendar: [AiringCalendarDay]
    var collections: [CollectionStatus: [UserAnimeCollection]]
    var episodes: [AnimeEpisode]
    var episodeProgress: [EpisodeProgress]
    var subjects: [AnimeSubject]
    var detail: SubjectDetail
    var error: BangumiAPIError?

    init(
        currentUser: BangumiUser = .preview,
        airingCalendar: [AiringCalendarDay] = [],
        collections: [CollectionStatus: [UserAnimeCollection]] = [:],
        episodes: [AnimeEpisode] = [],
        episodeProgress: [EpisodeProgress] = [],
        subjects: [AnimeSubject] = [.preview],
        detail: SubjectDetail = .preview,
        error: BangumiAPIError? = nil
    ) {
        self.currentUser = currentUser
        self.airingCalendar = airingCalendar
        self.collections = collections
        self.episodes = episodes
        self.episodeProgress = episodeProgress
        self.subjects = subjects
        self.detail = detail
        self.error = error
    }

    func me() async throws -> BangumiUser {
        if let error { throw error }
        return currentUser
    }

    func airingCalendar() async throws -> [AiringCalendarDay] {
        if let error { throw error }
        return airingCalendar
    }

    func userCollections(username: String, status: CollectionStatus, limit: Int, offset: Int) async throws -> [UserAnimeCollection] {
        if let error { throw error }
        let items = collections[status] ?? []
        return Self.page(of: items, limit: limit, offset: offset)
    }

    func updateCollection(subjectID: Int, status: CollectionStatus, rating: Int?, comment: String?, isPrivate: Bool) async throws {
        if let error { throw error }
    }

    func episodes(subjectID: Int) async throws -> [AnimeEpisode] {
        if let error { throw error }
        return episodes
    }

    func episodeProgress(subjectID: Int) async throws -> [EpisodeProgress] {
        if let error { throw error }
        if episodeProgress.isEmpty {
            return episodes.map { EpisodeProgress(episode: $0, status: .none) }
        }
        return episodeProgress
    }

    func updateEpisodeProgress(episodeID: Int, status: EpisodeCollectionStatus) async throws {
        if let error { throw error }
    }

    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects {
        if let error { throw error }
        let total = subjects.count
        let page = Self.page(of: subjects, limit: limit, offset: offset)
        return PagedSubjects(items: page, total: total, limit: limit, offset: offset)
    }

    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects {
        if let error { throw error }
        let filtered = subjects.filter {
            $0.displayName.localizedCaseInsensitiveContains(keyword) || $0.name.localizedCaseInsensitiveContains(keyword)
        }
        let total = filtered.count
        let page = Self.page(of: filtered, limit: limit, offset: offset)
        return PagedSubjects(items: page, total: total, limit: limit, offset: offset)
    }

    private static func page<T>(of items: [T], limit: Int, offset: Int) -> [T] {
        guard offset < items.count else { return [] }
        let end = min(offset + max(limit, 0), items.count)
        return Array(items[offset..<end])
    }

    func subject(id: Int) async throws -> SubjectDetail {
        if let error { throw error }
        return detail
    }
}

extension BangumiUser {
    static let preview = BangumiUser(
        id: 42,
        username: "bruce",
        nickname: "Bruce",
        avatarURL: URL(string: "https://lain.bgm.tv/pic/user/m/icon.jpg")
    )
}

extension AnimeSubject {
    static let preview = AnimeSubject(
        id: 1,
        name: "Cowboy Bebop",
        nameCN: "星际牛仔",
        summary: "A stylish space western anime.",
        imageURL: URL(string: "https://lain.bgm.tv/pic/cover/l/example.jpg"),
        rating: RatingSummary(score: 8.8, totalVotes: 12000),
        rank: 10
    )
}

extension SubjectDetail {
    static let preview = SubjectDetail(
        id: 1,
        name: "Cowboy Bebop",
        nameCN: "星际牛仔",
        summary: "A stylish space western anime.",
        imageURL: URL(string: "https://lain.bgm.tv/pic/cover/l/example.jpg"),
        rating: RatingSummary(score: 8.8, totalVotes: 12000),
        rank: 10,
        tags: ["科幻", "原创"],
        info: [SubjectInfo(key: "放送开始", value: "1998-04-03")]
    )
}
