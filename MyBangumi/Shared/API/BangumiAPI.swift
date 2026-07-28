protocol BangumiAPI: Sendable {
    func me() async throws -> BangumiUser
    func userCollections(username: String, status: CollectionStatus, limit: Int, offset: Int) async throws -> [UserAnimeCollection]
    func updateCollection(subjectID: Int, status: CollectionStatus, rating: Int?, comment: String?, isPrivate: Bool) async throws
    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects
    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects
    func subject(id: Int) async throws -> SubjectDetail
}
