import Foundation
import Testing
@testable import MyBangumi

struct DomainMappingTests {
    @Test func subjectUsesOriginalNameWhenChineseNameIsMissing() throws {
        let json = """
        {
          "id": 1,
          "name": "Cowboy Bebop",
          "name_cn": "",
          "summary": "",
          "images": {},
          "rating": { "score": 8.8, "total": 12000 },
          "rank": 10
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(BangumiSubjectDTO.self, from: json)
        #expect(dto.animeSubject.displayName == "Cowboy Bebop")
    }

    @Test func subjectImageURLUpgradesBangumiHTTPImageToHTTPS() throws {
        let json = """
        {
          "id": 1,
          "name": "Cowboy Bebop",
          "name_cn": "星际牛仔",
          "summary": "",
          "images": { "large": "http://lain.bgm.tv/pic/cover/l/example.jpg" },
          "rating": { "score": 8.8, "total": 12000 },
          "rank": 10
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(BangumiSubjectDTO.self, from: json)

        #expect(dto.animeSubject.imageURL?.scheme == "https")
        #expect(dto.animeSubject.imageURL?.host == "lain.bgm.tv")
    }

    @Test func pagedSearchResponseMapsItemsAndPagination() throws {
        let json = """
        {
          "total": 1,
          "limit": 20,
          "offset": 0,
          "items": [
            {
              "id": 2,
              "name": "AIR",
              "name_cn": "青空",
              "summary": "Summer story.",
              "images": { "common": "https://example.com/air.jpg" },
              "rating": { "score": 7.5, "total": 3000 },
              "rank": 200
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(BangumiSearchResponse.self, from: json)
        #expect(response.domain.items.first?.displayName == "青空")
        #expect(response.domain.hasMore == false)
    }

    @Test func mockBrowseSubjectsReturnsRequestedPage() async throws {
        let subjects = (1...5).map { index in
            AnimeSubject(
                id: index,
                name: "Anime \(index)",
                nameCN: "",
                summary: "",
                imageURL: nil,
                rating: RatingSummary(score: nil, totalVotes: 0),
                rank: nil
            )
        }
        let api = MockBangumiAPI(subjects: subjects, detail: .preview)

        let page = try await api.browseSubjects(type: .anime, sort: .rank, limit: 2, offset: 1)

        #expect(page.total == 5)
        #expect(page.items.map(\.id) == [2, 3])
        #expect(page.hasMore == true)
    }

    @Test func mockBrowseSubjectsReturnsEmptyPageForOutOfRangeOffset() async throws {
        let api = MockBangumiAPI(subjects: [.preview], detail: .preview)

        let page = try await api.browseSubjects(type: .anime, sort: .rank, limit: 10, offset: 5)

        #expect(page.total == 1)
        #expect(page.items.isEmpty)
        #expect(page.hasMore == false)
    }

    @Test func mockSearchSubjectsFiltersThenPaginates() async throws {
        let subjects = [
            AnimeSubject(id: 1, name: "Alpha", nameCN: "", summary: "", imageURL: nil, rating: RatingSummary(score: nil, totalVotes: 0), rank: nil),
            AnimeSubject(id: 2, name: "Beta", nameCN: "", summary: "", imageURL: nil, rating: RatingSummary(score: nil, totalVotes: 0), rank: nil),
            AnimeSubject(id: 3, name: "Gamma", nameCN: "", summary: "", imageURL: nil, rating: RatingSummary(score: nil, totalVotes: 0), rank: nil),
        ]
        let api = MockBangumiAPI(subjects: subjects, detail: .preview)

        let page = try await api.searchSubjects(keyword: "a", type: .anime, limit: 1, offset: 1)

        #expect(page.total == 3)
        #expect(page.items.map(\.id) == [2])
        #expect(page.hasMore == true)
    }
}
