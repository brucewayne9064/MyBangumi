struct PagedSubjects: Equatable, Sendable {
    let items: [AnimeSubject]
    let total: Int?
    let limit: Int
    let offset: Int

    var hasMore: Bool {
        guard let total else { return items.count == limit }
        return offset + items.count < total
    }
}
