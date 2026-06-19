import Foundation

struct MockBangumiAPI: BangumiAPI {
    var subjects: [AnimeSubject]
    var detail: SubjectDetail
    var error: BangumiAPIError?

    init(
        subjects: [AnimeSubject] = [.preview],
        detail: SubjectDetail = .preview,
        error: BangumiAPIError? = nil
    ) {
        self.subjects = subjects
        self.detail = detail
        self.error = error
    }

    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects {
        if let error { throw error }
        return PagedSubjects(items: subjects, total: subjects.count, limit: limit, offset: offset)
    }

    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects {
        if let error { throw error }
        let filtered = subjects.filter { $0.displayName.localizedCaseInsensitiveContains(keyword) || $0.name.localizedCaseInsensitiveContains(keyword) }
        return PagedSubjects(items: filtered, total: filtered.count, limit: limit, offset: offset)
    }

    func subject(id: Int) async throws -> SubjectDetail {
        if let error { throw error }
        return detail
    }
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
