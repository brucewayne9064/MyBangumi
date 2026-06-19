import Foundation

struct SubjectInfo: Equatable, Sendable {
    let key: String
    let value: String
}

struct SubjectDetail: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let nameCN: String
    let summary: String
    let imageURL: URL?
    let rating: RatingSummary
    let rank: Int?
    let tags: [String]
    let info: [SubjectInfo]

    var displayName: String {
        nameCN.isEmpty ? name : nameCN
    }
}
