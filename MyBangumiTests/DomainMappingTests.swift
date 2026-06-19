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
}
