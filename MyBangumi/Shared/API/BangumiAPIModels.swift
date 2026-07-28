import Foundation

struct BangumiUserDTO: Decodable {
    let id: Int
    let username: String
    let nickname: String
    let avatar: AvatarDTO?

    var domain: BangumiUser {
        BangumiUser(id: id, username: username, nickname: nickname, avatarURL: avatar?.mediumURL)
    }
}

struct AvatarDTO: Decodable {
    let large: String?
    let medium: String?
    let small: String?

    var mediumURL: URL? {
        medium.flatMap(URL.init(string:))
    }
}

struct BangumiPagedSubjectResponse: Decodable {
    let data: [BangumiSubjectDTO]
    let total: Int?
    let limit: Int?
    let offset: Int?

    var domain: PagedSubjects {
        PagedSubjects(
            items: data.map(\.animeSubject),
            total: total,
            limit: limit ?? data.count,
            offset: offset ?? 0
        )
    }
}

struct BangumiSearchResponse: Decodable {
    let total: Int?
    let limit: Int?
    let offset: Int?
    let items: [BangumiSubjectDTO]

    var domain: PagedSubjects {
        PagedSubjects(
            items: items.map(\.animeSubject),
            total: total,
            limit: limit ?? items.count,
            offset: offset ?? 0
        )
    }
}

struct BangumiPagedUserCollectionResponse: Decodable {
    let data: [BangumiUserCollectionDTO]

    var animeCollections: [UserAnimeCollection] {
        data.compactMap(\.domain)
    }
}

struct BangumiUserCollectionDTO: Decodable {
    let subject: BangumiSubjectDTO?
    let type: CollectionStatus
    let rate: Int?
    let comment: String?

    var domain: UserAnimeCollection? {
        guard let subject else { return nil }
        return UserAnimeCollection(
            subject: subject.animeSubject,
            status: type,
            rating: rate ?? 0,
            comment: comment ?? ""
        )
    }
}

struct BangumiPagedEpisodeResponse: Decodable {
    let data: [BangumiEpisodeDTO]

    var episodes: [AnimeEpisode] {
        data.map(\.domain)
    }
}

struct BangumiEpisodeDTO: Decodable {
    let id: Int
    let sort: Double
    let name: String
    let nameCN: String?
    let airdate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sort
        case name
        case nameCN = "name_cn"
        case airdate
    }

    var domain: AnimeEpisode {
        AnimeEpisode(id: id, sort: sort, name: name, nameCN: nameCN ?? "", airdate: airdate ?? "")
    }
}

struct BangumiEpisodeCollectionResponse: Decodable {
    let data: [BangumiEpisodeCollectionDTO]

    func progress(episodes: [AnimeEpisode]) -> [EpisodeProgress] {
        let statusByEpisodeID = Dictionary(uniqueKeysWithValues: data.map { ($0.episodeID, $0.type) })
        return episodes.map { episode in
            EpisodeProgress(episode: episode, status: statusByEpisodeID[episode.id] ?? .none)
        }
    }
}

struct BangumiEpisodeCollectionDTO: Decodable {
    let episodeID: Int
    let type: EpisodeCollectionStatus

    enum CodingKeys: String, CodingKey {
        case episodeID = "episode_id"
        case type
    }
}

struct BangumiSubjectDTO: Decodable {
    let id: Int
    let name: String
    let nameCN: String?
    let summary: String?
    let images: BangumiImagesDTO?
    let rating: BangumiRatingDTO?
    let rank: Int?
    let tags: [BangumiTagDTO]?
    let infobox: [BangumiInfoBoxDTO]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameCN = "name_cn"
        case summary
        case images
        case rating
        case rank
        case tags
        case infobox
    }

    var animeSubject: AnimeSubject {
        AnimeSubject(
            id: id,
            name: name,
            nameCN: nameCN ?? "",
            summary: summary ?? "",
            imageURL: images?.preferredURL,
            rating: RatingSummary(score: rating?.score, totalVotes: rating?.total ?? 0),
            rank: rank
        )
    }

    var detail: SubjectDetail {
        SubjectDetail(
            id: id,
            name: name,
            nameCN: nameCN ?? "",
            summary: summary ?? "",
            imageURL: images?.preferredURL,
            rating: RatingSummary(score: rating?.score, totalVotes: rating?.total ?? 0),
            rank: rank,
            tags: tags?.map(\.name) ?? [],
            info: infobox?.compactMap(\.domain) ?? []
        )
    }
}

struct BangumiImagesDTO: Decodable {
    let large: String?
    let common: String?
    let medium: String?

    var preferredURL: URL? {
        [large, common, medium]
            .compactMap { $0 }
            .compactMap(URL.init(string:))
            .first
    }
}

struct BangumiRatingDTO: Decodable {
    let score: Double?
    let total: Int?
}

struct BangumiTagDTO: Decodable {
    let name: String
}

struct BangumiInfoBoxDTO: Decodable {
    let key: String
    let value: StringValue

    var domain: SubjectInfo? {
        switch value {
        case .string(let string):
            SubjectInfo(key: key, value: string)
        case .array(let values):
            SubjectInfo(key: key, value: values.joined(separator: "、"))
        }
    }
}

enum StringValue: Decodable {
    case string(String)
    case array([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        if let array = try? container.decode([String].self) {
            self = .array(array)
            return
        }
        self = .string("")
    }
}
