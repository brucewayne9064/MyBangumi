import Foundation

actor InMemorySubjectCache {
    private var details: [Int: SubjectDetail] = [:]

    func detail(for id: Int) -> SubjectDetail? {
        details[id]
    }

    func store(_ detail: SubjectDetail) {
        details[detail.id] = detail
    }

    func clear() {
        details.removeAll()
    }
}
