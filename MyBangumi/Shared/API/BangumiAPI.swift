protocol BangumiAPI: Sendable {
    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects
    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects
    func subject(id: Int) async throws -> SubjectDetail
}
