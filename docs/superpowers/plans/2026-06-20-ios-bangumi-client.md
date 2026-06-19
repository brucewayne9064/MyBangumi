# iOS Bangumi Client Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first working vertical slice of a native iOS 26 Bangumi anime browsing client with Discover, Database, My, Search, and Subject Detail.

**Architecture:** Use MVVM + feature modules. Views render state only; view models own loading state and call a protocol-first `BangumiAPI`. Shared API, domain, design-system, and cache code lives under `MyBangumi/Shared`.

**Tech Stack:** SwiftUI, Swift Observation, async/await, URLSession, Swift Testing, XCTest UI tests, AsyncImage, no third-party dependencies.

## Global Constraints

- Product: App.
- Interface: SwiftUI.
- Language: Swift.
- Testing System: Swift Testing.
- Storage: None.
- Minimum Deployment Target: iOS 26.0.
- Do not enable SwiftData.
- Do not add third-party dependencies.
- Use `AsyncImage` only for remote images.
- Use MVVM + feature modules.
- Views must not perform networking.
- All network requests go through `BangumiAPI`.
- View models own loading state.
- Views only render state and send user intents to view models.
- Search input must be debounced between 300ms and 500ms.
- The first implementation must compile and run after each milestone.
- Each milestone must end with relevant tests passing and a git commit.

---

## File Structure

Create or modify these files during implementation:

- `MyBangumi/MyBangumiApp.swift`: app entry point and production dependency setup.
- `MyBangumi/ContentView.swift`: root tab shell.
- `MyBangumi/Shared/API/BangumiAPI.swift`: API protocol and shared request enums.
- `MyBangumi/Shared/API/BangumiAPIClient.swift`: URLSession implementation.
- `MyBangumi/Shared/API/BangumiAPIError.swift`: typed API errors.
- `MyBangumi/Shared/API/BangumiAPIModels.swift`: response DTOs.
- `MyBangumi/Shared/API/MockBangumiAPI.swift`: deterministic mock for tests and previews.
- `MyBangumi/Shared/Domain/AnimeSubject.swift`: list subject model.
- `MyBangumi/Shared/Domain/SubjectDetail.swift`: detail model.
- `MyBangumi/Shared/Domain/PagedSubjects.swift`: paged result model.
- `MyBangumi/Shared/DesignSystem/GlassPanel.swift`: shared glass panel.
- `MyBangumi/Shared/DesignSystem/SubjectPosterView.swift`: AsyncImage poster view.
- `MyBangumi/Shared/DesignSystem/SubjectCardView.swift`: reusable anime card.
- `MyBangumi/Shared/DesignSystem/LoadableStateView.swift`: loading, empty, error rendering helpers.
- `MyBangumi/Shared/Cache/InMemorySubjectCache.swift`: in-memory subject/detail cache.
- `MyBangumi/Features/Discover/DiscoverView.swift`
- `MyBangumi/Features/Discover/DiscoverViewModel.swift`
- `MyBangumi/Features/Database/DatabaseView.swift`
- `MyBangumi/Features/Database/DatabaseViewModel.swift`
- `MyBangumi/Features/Search/SearchView.swift`
- `MyBangumi/Features/Search/SearchViewModel.swift`
- `MyBangumi/Features/SubjectDetail/SubjectDetailView.swift`
- `MyBangumi/Features/SubjectDetail/SubjectDetailViewModel.swift`
- `MyBangumi/Features/Profile/ProfileView.swift`
- `MyBangumiTests/BangumiAPIClientTests.swift`
- `MyBangumiTests/DomainMappingTests.swift`
- `MyBangumiTests/ViewModelStateTests.swift`
- `MyBangumiUITests/MyBangumiUITests.swift`
- `MyBangumi.xcodeproj/project.pbxproj`: update deployment target from 26.2 to 26.0.

Because this Xcode project uses file-system synchronized groups, new Swift files under `MyBangumi/`, `MyBangumiTests/`, and `MyBangumiUITests/` should be picked up without manually editing build phase file lists. Verify with `xcodebuild` after each task.

---

### Task 1: Project Baseline And Root Navigation

**Files:**
- Modify: `MyBangumi.xcodeproj/project.pbxproj`
- Modify: `MyBangumi/ContentView.swift`
- Create: `MyBangumi/Features/Discover/DiscoverView.swift`
- Create: `MyBangumi/Features/Database/DatabaseView.swift`
- Create: `MyBangumi/Features/Profile/ProfileView.swift`
- Create: `MyBangumi/Features/Search/SearchView.swift`
- Test: `MyBangumiUITests/MyBangumiUITests.swift`

**Interfaces:**
- Produces: `ContentView` with four tabs labeled `发现`, `数据库`, `我的`, `搜索`.
- Produces: feature view shells that later tasks replace with real state.

- [ ] **Step 1: Set deployment target to iOS 26.0**

Update every `IPHONEOS_DEPLOYMENT_TARGET = 26.2;` entry in `MyBangumi.xcodeproj/project.pbxproj` to:

```text
IPHONEOS_DEPLOYMENT_TARGET = 26.0;
```

Run:

```bash
rg "IPHONEOS_DEPLOYMENT_TARGET" MyBangumi.xcodeproj/project.pbxproj
```

Expected: every app and test target deployment target is `26.0`.

- [ ] **Step 2: Create shell feature views**

Create `MyBangumi/Features/Discover/DiscoverView.swift`:

```swift
import SwiftUI

struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            Text("发现")
                .font(.largeTitle.bold())
                .navigationTitle("发现")
        }
    }
}

#Preview {
    DiscoverView()
}
```

Create `MyBangumi/Features/Database/DatabaseView.swift`:

```swift
import SwiftUI

struct DatabaseView: View {
    var body: some View {
        NavigationStack {
            Text("数据库")
                .font(.largeTitle.bold())
                .navigationTitle("数据库")
        }
    }
}

#Preview {
    DatabaseView()
}
```

Create `MyBangumi/Features/Profile/ProfileView.swift`:

```swift
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("我的")
                .font(.largeTitle.bold())
                .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
}
```

Create `MyBangumi/Features/Search/SearchView.swift`:

```swift
import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            Text("搜索")
                .font(.largeTitle.bold())
                .navigationTitle("搜索")
        }
    }
}

#Preview {
    SearchView()
}
```

- [ ] **Step 3: Replace `ContentView` with the tab shell**

Replace `MyBangumi/ContentView.swift` with:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Label("发现", systemImage: "sparkles")
                }

            DatabaseView()
                .tabItem {
                    Label("数据库", systemImage: "rectangle.stack")
                }

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle")
                }

            SearchView()
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ContentView()
}
```

- [ ] **Step 4: Update UI smoke test for four tabs**

Replace `MyBangumiUITests/MyBangumiUITests.swift` with:

```swift
import XCTest

final class MyBangumiUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRootTabsExist() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["发现"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["数据库"].exists)
        XCTAssertTrue(app.tabBars.buttons["我的"].exists)
        XCTAssertTrue(app.tabBars.buttons["搜索"].exists)
    }
}
```

- [ ] **Step 5: Verify build and tests**

Run:

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' build
```

Expected: `** BUILD SUCCEEDED **`.

Run UI tests from Xcode if the generic destination cannot execute UI tests. The root tabs must be visible.

- [ ] **Step 6: Commit**

```bash
git add MyBangumi.xcodeproj/project.pbxproj MyBangumi MyBangumiUITests
git commit -m "Build root tab navigation"
```

---

### Task 2: Domain Models And Protocol-First API

**Files:**
- Create: `MyBangumi/Shared/Domain/AnimeSubject.swift`
- Create: `MyBangumi/Shared/Domain/SubjectDetail.swift`
- Create: `MyBangumi/Shared/Domain/PagedSubjects.swift`
- Create: `MyBangumi/Shared/API/BangumiAPI.swift`
- Create: `MyBangumi/Shared/API/BangumiAPIError.swift`
- Create: `MyBangumi/Shared/API/BangumiAPIModels.swift`
- Create: `MyBangumi/Shared/API/MockBangumiAPI.swift`
- Test: `MyBangumiTests/DomainMappingTests.swift`

**Interfaces:**
- Produces: `SubjectType.anime`, `SubjectSort`, `AnimeSubject`, `SubjectDetail`, `PagedSubjects`.
- Produces: `BangumiAPI` protocol consumed by all view models.
- Produces: `MockBangumiAPI` consumed by tests and previews.

- [ ] **Step 1: Add domain models**

Create `MyBangumi/Shared/Domain/AnimeSubject.swift`:

```swift
import Foundation

enum SubjectType: Int, Codable, Sendable {
    case anime = 2
}

enum SubjectSort: String, Codable, Sendable, CaseIterable {
    case rank
    case date
}

struct RatingSummary: Equatable, Sendable {
    let score: Double?
    let totalVotes: Int
}

struct AnimeSubject: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let nameCN: String
    let summary: String
    let imageURL: URL?
    let rating: RatingSummary
    let rank: Int?

    var displayName: String {
        nameCN.isEmpty ? name : nameCN
    }
}
```

Create `MyBangumi/Shared/Domain/SubjectDetail.swift`:

```swift
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
```

Create `MyBangumi/Shared/Domain/PagedSubjects.swift`:

```swift
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
```

- [ ] **Step 2: Add API protocol and error types**

Create `MyBangumi/Shared/API/BangumiAPIError.swift`:

```swift
import Foundation

enum BangumiAPIError: Error, Equatable, LocalizedError, Sendable {
    case invalidURL
    case transport(String)
    case server(statusCode: Int)
    case decoding(endpoint: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "无法创建请求地址。"
        case .transport:
            "网络连接失败，请稍后重试。"
        case .server(let statusCode):
            "Bangumi 服务暂时不可用。（\(statusCode)）"
        case .decoding:
            "返回数据暂时无法识别。"
        }
    }
}
```

Create `MyBangumi/Shared/API/BangumiAPI.swift`:

```swift
protocol BangumiAPI: Sendable {
    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects
    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects
    func subject(id: Int) async throws -> SubjectDetail
}
```

- [ ] **Step 3: Add DTOs and mappers**

Create `MyBangumi/Shared/API/BangumiAPIModels.swift` with:

```swift
import Foundation

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
```

- [ ] **Step 4: Add mock API**

Create `MyBangumi/Shared/API/MockBangumiAPI.swift`:

```swift
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
```

- [ ] **Step 5: Add domain mapping tests**

Create `MyBangumiTests/DomainMappingTests.swift`:

```swift
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
```

- [ ] **Step 6: Run tests**

Run:

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: domain mapping tests pass. If generic simulator cannot run tests in the local environment, run the same tests from Xcode and record the simulator used.

- [ ] **Step 7: Commit**

```bash
git add MyBangumi/Shared MyBangumiTests
git commit -m "Add Bangumi domain and API contracts"
```

---

### Task 3: URLSession API Client

**Files:**
- Create: `MyBangumi/Shared/API/BangumiAPIClient.swift`
- Test: `MyBangumiTests/BangumiAPIClientTests.swift`

**Interfaces:**
- Consumes: `BangumiAPI`, `BangumiAPIError`, response DTOs, domain models.
- Produces: `BangumiAPIClient` used by app setup and view models.

- [ ] **Step 1: Add `BangumiAPIClient`**

Create `MyBangumi/Shared/API/BangumiAPIClient.swift`:

```swift
import Foundation

struct BangumiAPIClient: BangumiAPI {
    private let baseURL: URL
    private let session: URLSession
    private let userAgent: String

    init(
        baseURL: URL = URL(string: "https://api.bgm.tv")!,
        session: URLSession = .shared,
        userAgent: String = "MyBangumi/1.0 (iOS; https://github.com/brucewayne9064/MyBangumi)"
    ) {
        self.baseURL = baseURL
        self.session = session
        self.userAgent = userAgent
    }

    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects {
        var components = URLComponents(url: baseURL.appending(path: "/v0/subjects"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "type", value: String(type.rawValue)),
            URLQueryItem(name: "sort", value: sort.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        let response: BangumiPagedSubjectResponse = try await send(components?.url, method: "GET", body: Optional<Data>.none, endpoint: "/v0/subjects")
        return response.domain
    }

    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects {
        let url = baseURL.appending(path: "/v0/search/subjects")
        let body = SearchRequest(keyword: keyword, filter: SearchFilter(type: [type.rawValue]))
        let data = try JSONEncoder().encode(body)
        let response: BangumiSearchResponse = try await send(url, method: "POST", body: data, endpoint: "/v0/search/subjects", query: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ])
        return response.domain
    }

    func subject(id: Int) async throws -> SubjectDetail {
        let response: BangumiSubjectDTO = try await send(baseURL.appending(path: "/v0/subjects/\(id)"), method: "GET", body: Optional<Data>.none, endpoint: "/v0/subjects/{id}")
        return response.detail
    }

    private func send<Response: Decodable>(
        _ url: URL?,
        method: String,
        body: Data?,
        endpoint: String,
        query: [URLQueryItem] = []
    ) async throws -> Response {
        guard var url else { throw BangumiAPIError.invalidURL }
        if !query.isEmpty {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = query
            guard let composedURL = components?.url else { throw BangumiAPIError.invalidURL }
            url = composedURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw BangumiAPIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BangumiAPIError.transport("Missing HTTP response")
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw BangumiAPIError.server(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw BangumiAPIError.decoding(endpoint: endpoint)
        }
    }
}

private struct SearchRequest: Encodable {
    let keyword: String
    let filter: SearchFilter
}

private struct SearchFilter: Encodable {
    let type: [Int]
}
```

- [ ] **Step 2: Add URLProtocol test transport**

Create `MyBangumiTests/BangumiAPIClientTests.swift`:

```swift
import Foundation
import Testing
@testable import MyBangumi

final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

struct BangumiAPIClientTests {
    @Test func browseSubjectsBuildsExpectedRequestAndUserAgent() async throws {
        let client = makeClient()
        URLProtocolStub.handler = { request in
            #expect(request.url?.path == "/v0/subjects")
            #expect(request.value(forHTTPHeaderField: "User-Agent")?.contains("MyBangumi") == true)

            let data = """
            { "data": [], "total": 0, "limit": 20, "offset": 0 }
            """.data(using: .utf8)!
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }

        let result = try await client.browseSubjects(type: .anime, sort: .rank, limit: 20, offset: 0)
        #expect(result.items.isEmpty)
    }

    @Test func nonSuccessStatusMapsToServerError() async throws {
        let client = makeClient()
        URLProtocolStub.handler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!, Data())
        }

        do {
            _ = try await client.subject(id: 1)
            Issue.record("Expected server error")
        } catch let error as BangumiAPIError {
            #expect(error == .server(statusCode: 503))
        }
    }

    private func makeClient() -> BangumiAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return BangumiAPIClient(baseURL: URL(string: "https://api.example.test")!, session: session)
    }
}
```

- [ ] **Step 3: Run API tests**

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: `BangumiAPIClientTests` and `DomainMappingTests` pass.

- [ ] **Step 4: Commit**

```bash
git add MyBangumi/Shared/API MyBangumiTests
git commit -m "Implement Bangumi API client"
```

---

### Task 4: Shared Design System

**Files:**
- Create: `MyBangumi/Shared/DesignSystem/GlassPanel.swift`
- Create: `MyBangumi/Shared/DesignSystem/SubjectPosterView.swift`
- Create: `MyBangumi/Shared/DesignSystem/SubjectCardView.swift`
- Create: `MyBangumi/Shared/DesignSystem/LoadableStateView.swift`

**Interfaces:**
- Consumes: `AnimeSubject`.
- Produces: reusable components consumed by feature views.

- [ ] **Step 1: Add glass panel**

Create `MyBangumi/Shared/DesignSystem/GlassPanel.swift` and keep Liquid Glass usage centralized here:

```swift
import SwiftUI

struct GlassPanel<Content: View>: View {
    private let material: Material
    private let content: Content

    init(material: Material = .thinMaterial, @ViewBuilder content: () -> Content) {
        self.material = material
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(material, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .glassEffect()
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }
    }
}
```

If the local iOS 26 SDK requires arguments for `glassEffect`, adjust only this shared component to the SDK's exact signature and keep the same external `GlassPanel` API. Do not scatter `glassEffect` calls across feature views.

- [ ] **Step 2: Add poster and card views**

Create `MyBangumi/Shared/DesignSystem/SubjectPosterView.swift`:

```swift
import SwiftUI

struct SubjectPosterView: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                fallback
                    .overlay { ProgressView() }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                fallback
            @unknown default:
                fallback
            }
        }
        .frame(width: 92, height: 132)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        LinearGradient(
            colors: [.blue.opacity(0.55), .purple.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
```

Create `MyBangumi/Shared/DesignSystem/SubjectCardView.swift`:

```swift
import SwiftUI

struct SubjectCardView: View {
    let subject: AnimeSubject

    var body: some View {
        GlassPanel {
            HStack(alignment: .top, spacing: 14) {
                SubjectPosterView(url: subject.imageURL)

                VStack(alignment: .leading, spacing: 8) {
                    Text(subject.displayName)
                        .font(.headline)
                        .lineLimit(2)

                    if !subject.nameCN.isEmpty && subject.nameCN != subject.name {
                        Text(subject.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        if let score = subject.rating.score {
                            Text(String(format: "%.1f", score))
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.regularMaterial, in: Capsule())
                        }
                        if let rank = subject.rank {
                            Text("#\(rank)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(subject.summary.isEmpty ? "暂无简介" : subject.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
    }
}
```

- [ ] **Step 3: Add reusable state view**

Create `MyBangumi/Shared/DesignSystem/LoadableStateView.swift`:

```swift
import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Button("重试", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
```

- [ ] **Step 4: Verify build**

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' build
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add MyBangumi/Shared/DesignSystem
git commit -m "Add shared design system components"
```

---

### Task 5: Discover And Database Real Data

**Files:**
- Modify: `MyBangumi/MyBangumiApp.swift`
- Modify: `MyBangumi/ContentView.swift`
- Modify: `MyBangumi/Features/Discover/DiscoverView.swift`
- Create: `MyBangumi/Features/Discover/DiscoverViewModel.swift`
- Modify: `MyBangumi/Features/Database/DatabaseView.swift`
- Create: `MyBangumi/Features/Database/DatabaseViewModel.swift`
- Test: `MyBangumiTests/ViewModelStateTests.swift`

**Interfaces:**
- Consumes: `BangumiAPI`, `SubjectCardView`.
- Produces: Discover and Database screens using real API in production and mock API in tests/previews.

- [ ] **Step 1: Add view models**

Create `MyBangumi/Features/Discover/DiscoverViewModel.swift`:

```swift
import Observation

@Observable
final class DiscoverViewModel {
    enum ModuleState: Equatable {
        case loading
        case loaded([AnimeSubject])
        case failed(String)
    }

    private let api: any BangumiAPI
    var ranked: ModuleState = .loading
    var recent: ModuleState = .loading

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func load() async {
        async let rankedLoad: Void = loadRanked()
        async let recentLoad: Void = loadRecent()
        _ = await (rankedLoad, recentLoad)
    }

    @MainActor
    private func loadRanked() async {
        ranked = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: .rank, limit: 10, offset: 0)
            ranked = .loaded(page.items)
        } catch {
            ranked = .failed(error.localizedDescription)
        }
    }

    @MainActor
    private func loadRecent() async {
        recent = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: .date, limit: 10, offset: 0)
            recent = .loaded(page.items)
        } catch {
            recent = .failed(error.localizedDescription)
        }
    }
}
```

Create `MyBangumi/Features/Database/DatabaseViewModel.swift`:

```swift
import Observation

@Observable
final class DatabaseViewModel {
    enum State: Equatable {
        case loading
        case loaded(PagedSubjects)
        case failed(String)
    }

    private let api: any BangumiAPI
    private let limit = 20
    var sort: SubjectSort = .rank
    var state: State = .loading

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func load(offset: Int = 0) async {
        state = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: sort, limit: limit, offset: offset)
            state = .loaded(page)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
```

- [ ] **Step 2: Inject API through root content**

Modify `MyBangumi/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    let api: any BangumiAPI

    init(api: any BangumiAPI = BangumiAPIClient()) {
        self.api = api
    }

    var body: some View {
        TabView {
            DiscoverView(viewModel: DiscoverViewModel(api: api))
                .tabItem { Label("发现", systemImage: "sparkles") }

            DatabaseView(viewModel: DatabaseViewModel(api: api))
                .tabItem { Label("数据库", systemImage: "rectangle.stack") }

            ProfileView()
                .tabItem { Label("我的", systemImage: "person.crop.circle") }

            SearchView()
                .tabItem { Label("搜索", systemImage: "magnifyingglass") }
        }
    }
}

#Preview {
    ContentView(api: MockBangumiAPI())
}
```

- [ ] **Step 3: Render Discover modules**

Replace `MyBangumi/Features/Discover/DiscoverView.swift` with:

```swift
import SwiftUI

struct DiscoverView: View {
    @State var viewModel: DiscoverViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    module(title: "高分动画", state: viewModel.ranked)
                    module(title: "近期动画", state: viewModel.recent)
                }
                .padding()
            }
            .navigationTitle("发现")
            .task {
                await viewModel.load()
            }
        }
    }

    @ViewBuilder
    private func module(title: String, state: DiscoverViewModel.ModuleState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            switch state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
            case .loaded(let subjects):
                if subjects.isEmpty {
                    EmptyStateView(title: "暂无内容", message: "这个模块暂时没有可展示的动画。")
                } else {
                    ForEach(subjects) { subject in
                        SubjectCardView(subject: subject)
                    }
                }
            case .failed(let message):
                ErrorStateView(message: message) {
                    Task { await viewModel.load() }
                }
            }
        }
    }
}

#Preview {
    DiscoverView(viewModel: DiscoverViewModel(api: MockBangumiAPI()))
}
```

- [ ] **Step 4: Render Database list**

Replace `MyBangumi/Features/Database/DatabaseView.swift` with:

```swift
import SwiftUI

struct DatabaseView: View {
    @State var viewModel: DatabaseViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                case .loaded(let page):
                    if page.items.isEmpty {
                        EmptyStateView(title: "暂无条目", message: "当前排序下没有动画条目。")
                    } else {
                        List(page.items) { subject in
                            SubjectCardView(subject: subject)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.load() }
                    }
                }
            }
            .navigationTitle("数据库")
            .toolbar {
                Picker("排序", selection: $viewModel.sort) {
                    Text("排名").tag(SubjectSort.rank)
                    Text("日期").tag(SubjectSort.date)
                }
            }
            .task {
                await viewModel.load()
            }
            .onChange(of: viewModel.sort) {
                Task { await viewModel.load() }
            }
        }
    }
}

#Preview {
    DatabaseView(viewModel: DatabaseViewModel(api: MockBangumiAPI()))
}
```

- [ ] **Step 5: Add view model tests**

Create `MyBangumiTests/ViewModelStateTests.swift`:

```swift
import Testing
@testable import MyBangumi

struct ViewModelStateTests {
    @Test func databaseLoadsSubjects() async {
        let viewModel = DatabaseViewModel(api: MockBangumiAPI(subjects: [.preview]))
        await viewModel.load()

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(page.items == [.preview])
    }

    @Test func databaseMapsErrorsToFailedState() async {
        let viewModel = DatabaseViewModel(api: MockBangumiAPI(error: .server(statusCode: 500)))
        await viewModel.load()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }
        #expect(message.isEmpty == false)
    }
}
```

- [ ] **Step 6: Verify build and tests**

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: build and unit tests pass.

- [ ] **Step 7: Commit**

```bash
git add MyBangumi MyBangumiTests
git commit -m "Load discover and database anime data"
```

---

### Task 6: Dedicated Search With Debounce And Load More

**Files:**
- Modify: `MyBangumi/ContentView.swift`
- Modify: `MyBangumi/Features/Search/SearchView.swift`
- Create: `MyBangumi/Features/Search/SearchViewModel.swift`
- Test: `MyBangumiTests/SearchViewModelTests.swift`

**Interfaces:**
- Consumes: `BangumiAPI`.
- Produces: dedicated `SearchView` tab with debounced keyword search and one explicit load-more action.

- [ ] **Step 1: Add search view model**

Create `MyBangumi/Features/Search/SearchViewModel.swift`:

```swift
import Foundation
import Observation

@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(PagedSubjects)
        case empty
        case failed(String)
    }

    private let api: any BangumiAPI
    private let limit = 20
    private var searchTask: Task<Void, Never>?

    var keyword = ""
    var state: State = .idle

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func keywordChanged(to value: String) {
        keyword = value
        searchTask?.cancel()

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            state = .idle
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard Task.isCancelled == false else { return }
            await self?.search(keyword: trimmed, offset: 0)
        }
    }

    @MainActor
    func search(keyword: String, offset: Int) async {
        state = .loading
        do {
            let page = try await api.searchSubjects(keyword: keyword, type: .anime, limit: limit, offset: offset)
            state = page.items.isEmpty ? .empty : .loaded(page)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    @MainActor
    func loadMore() async {
        guard case .loaded(let current) = state, current.hasMore else { return }
        do {
            let next = try await api.searchSubjects(keyword: keyword, type: .anime, limit: limit, offset: current.offset + current.items.count)
            state = .loaded(PagedSubjects(
                items: current.items + next.items,
                total: next.total,
                limit: limit,
                offset: 0
            ))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
```

- [ ] **Step 2: Render SearchView**

Replace `MyBangumi/Features/Search/SearchView.swift` with:

```swift
import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    EmptyStateView(title: "搜索动画", message: "输入关键词查找 Bangumi 动画条目。")
                case .loading:
                    ProgressView()
                case .empty:
                    EmptyStateView(title: "没有结果", message: "换一个关键词试试。")
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.search(keyword: viewModel.keyword, offset: 0) }
                    }
                case .loaded(let page):
                    List {
                        ForEach(page.items) { subject in
                            SubjectCardView(subject: subject)
                                .listRowSeparator(.hidden)
                        }
                        if page.hasMore {
                            Button("加载更多") {
                                Task { await viewModel.loadMore() }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("搜索")
            .searchable(text: Binding(
                get: { viewModel.keyword },
                set: { viewModel.keywordChanged(to: $0) }
            ), prompt: "搜索动画")
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel(api: MockBangumiAPI()))
}
```

Update `ContentView` search tab:

```swift
SearchView(viewModel: SearchViewModel(api: api))
    .tabItem { Label("搜索", systemImage: "magnifyingglass") }
```

- [ ] **Step 3: Add search tests**

Create `MyBangumiTests/SearchViewModelTests.swift`:

```swift
import Testing
@testable import MyBangumi

struct SearchViewModelTests {
    @Test func emptyKeywordReturnsIdleState() async {
        let viewModel = SearchViewModel(api: MockBangumiAPI())
        await viewModel.keywordChanged(to: "   ")
        #expect(viewModel.state == .idle)
    }

    @Test func explicitSearchLoadsMatchingSubjects() async {
        let viewModel = SearchViewModel(api: MockBangumiAPI(subjects: [.preview]))
        await viewModel.search(keyword: "星际", offset: 0)

        guard case .loaded(let page) = viewModel.state else {
            Issue.record("Expected loaded search state")
            return
        }
        #expect(page.items.first?.displayName == "星际牛仔")
    }
}
```

- [ ] **Step 4: Verify**

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: search tests pass and app builds.

- [ ] **Step 5: Commit**

```bash
git add MyBangumi/Features/Search MyBangumi/ContentView.swift MyBangumiTests
git commit -m "Add debounced anime search"
```

---

### Task 7: Subject Detail And Profile Page

**Files:**
- Modify: `MyBangumi/Features/Discover/DiscoverView.swift`
- Modify: `MyBangumi/Features/Database/DatabaseView.swift`
- Modify: `MyBangumi/Features/Search/SearchView.swift`
- Create: `MyBangumi/Features/SubjectDetail/SubjectDetailView.swift`
- Create: `MyBangumi/Features/SubjectDetail/SubjectDetailViewModel.swift`
- Modify: `MyBangumi/Features/Profile/ProfileView.swift`
- Test: `MyBangumiTests/SubjectDetailViewModelTests.swift`

**Interfaces:**
- Consumes: `BangumiAPI.subject(id:)`.
- Produces: detail navigation from Discover, Database, and Search.
- Produces: unauthenticated My page with future login/collection/progress messaging and settings information.

- [ ] **Step 1: Add detail view model**

Create `MyBangumi/Features/SubjectDetail/SubjectDetailViewModel.swift`:

```swift
import Observation

@Observable
final class SubjectDetailViewModel {
    enum State: Equatable {
        case loading
        case loaded(SubjectDetail)
        case failed(String)
    }

    private let api: any BangumiAPI
    let subject: AnimeSubject
    var state: State = .loading

    init(subject: AnimeSubject, api: any BangumiAPI) {
        self.subject = subject
        self.api = api
    }

    @MainActor
    func load() async {
        state = .loading
        do {
            state = .loaded(try await api.subject(id: subject.id))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
```

- [ ] **Step 2: Add detail view**

Create `MyBangumi/Features/SubjectDetail/SubjectDetailView.swift`:

```swift
import SwiftUI

struct SubjectDetailView: View {
    @State var viewModel: SubjectDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                content
            }
            .padding()
        }
        .navigationTitle(viewModel.subject.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            SubjectPosterView(url: viewModel.subject.imageURL)
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.subject.displayName)
                    .font(.title2.bold())
                if !viewModel.subject.name.isEmpty {
                    Text(viewModel.subject.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let score = viewModel.subject.rating.score {
                    Text(String(format: "评分 %.1f", score))
                        .font(.subheadline.bold())
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded(let detail):
            detailContent(detail)
        }
    }

    private func detailContent(_ detail: SubjectDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            section(title: "简介", text: detail.summary.isEmpty ? "暂无简介" : detail.summary)

            if detail.tags.isEmpty == false {
                Text("标签")
                    .font(.headline)
                FlowTags(tags: detail.tags)
            }

            if detail.info.isEmpty == false {
                Text("信息")
                    .font(.headline)
                ForEach(detail.info, id: \.key) { item in
                    HStack(alignment: .top) {
                        Text(item.key)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.value)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private func section(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.body)
        }
    }
}

private struct FlowTags: View {
    let tags: [String]

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }
        }
    }
}
```

- [ ] **Step 3: Add navigation links**

In Discover, Database, and Search lists, wrap each `SubjectCardView` with:

```swift
NavigationLink {
    SubjectDetailView(viewModel: SubjectDetailViewModel(subject: subject, api: viewModel.api))
} label: {
    SubjectCardView(subject: subject)
}
```

To support this, expose the feature view model API dependency as:

```swift
let api: any BangumiAPI
```

instead of `private let api`.

- [ ] **Step 4: Replace Profile page**

Replace `MyBangumi/Features/Profile/ProfileView.swift` with:

```swift
import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("登录与同步")
                            .font(.headline)
                        Text("Bangumi 登录、收藏、追番进度和章节管理将在后续版本支持。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("关于") {
                    LabeledContent("数据来源", value: "Bangumi Public API")
                    LabeledContent("缓存策略", value: "内存缓存")
                    Link("GitHub", destination: URL(string: "https://github.com/brucewayne9064/MyBangumi")!)
                }
            }
            .navigationTitle("我的")
        }
    }
}

#Preview {
    ProfileView()
}
```

- [ ] **Step 5: Add detail state test**

Create `MyBangumiTests/SubjectDetailViewModelTests.swift`:

```swift
import Testing
@testable import MyBangumi

struct SubjectDetailViewModelTests {
    @Test func detailLoadsSubject() async {
        let viewModel = SubjectDetailViewModel(subject: .preview, api: MockBangumiAPI(detail: .preview))
        await viewModel.load()

        guard case .loaded(let detail) = viewModel.state else {
            Issue.record("Expected loaded detail")
            return
        }
        #expect(detail.displayName == "星际牛仔")
    }
}
```

- [ ] **Step 6: Verify build and tests**

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: build and tests pass.

- [ ] **Step 7: Commit**

```bash
git add MyBangumi MyBangumiTests
git commit -m "Add subject detail and profile pages"
```

---

### Task 8: In-Memory Cache, UI Smoke, And Final Verification

**Files:**
- Create: `MyBangumi/Shared/Cache/InMemorySubjectCache.swift`
- Modify: `MyBangumi/Shared/API/BangumiAPIClient.swift`
- Modify: `MyBangumiUITests/MyBangumiUITests.swift`
- Modify: `docs/superpowers/specs/2026-06-20-ios-bangumi-client-design.md` only if implementation discovers a verified spec mismatch.

**Interfaces:**
- Consumes: `SubjectDetail`, `PagedSubjects`.
- Produces: lightweight in-memory cache for repeated detail loads.
- Produces: final launch and tab navigation smoke coverage.

- [ ] **Step 1: Add in-memory cache**

Create `MyBangumi/Shared/Cache/InMemorySubjectCache.swift`:

```swift
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
```

- [ ] **Step 2: Wire cache into detail requests**

Update `BangumiAPIClient` with a cache property:

```swift
private let cache: InMemorySubjectCache
```

Update the initializer:

```swift
init(
    baseURL: URL = URL(string: "https://api.bgm.tv")!,
    session: URLSession = .shared,
    userAgent: String = "MyBangumi/1.0 (iOS; https://github.com/brucewayne9064/MyBangumi)",
    cache: InMemorySubjectCache = InMemorySubjectCache()
) {
    self.baseURL = baseURL
    self.session = session
    self.userAgent = userAgent
    self.cache = cache
}
```

Update `subject(id:)`:

```swift
func subject(id: Int) async throws -> SubjectDetail {
    if let cached = await cache.detail(for: id) {
        return cached
    }
    let response: BangumiSubjectDTO = try await send(baseURL.appending(path: "/v0/subjects/\(id)"), method: "GET", body: Optional<Data>.none, endpoint: "/v0/subjects/{id}")
    let detail = response.detail
    await cache.store(detail)
    return detail
}
```

- [ ] **Step 3: Update UI smoke test**

Keep `testRootTabsExist` and add:

```swift
@MainActor
func testCanSwitchBetweenAllTabs() throws {
    let app = XCUIApplication()
    app.launch()

    for title in ["发现", "数据库", "我的", "搜索"] {
        app.tabBars.buttons[title].tap()
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 3))
    }
}
```

- [ ] **Step 4: Full verification**

Run:

```bash
xcodebuild -project MyBangumi.xcodeproj -scheme MyBangumi -destination 'generic/platform=iOS Simulator' test
```

Expected: unit tests pass.

Run the app in an iOS 26 simulator from Xcode and manually verify:

- Bottom tabs are `发现`, `数据库`, `我的`, `搜索`.
- Discover loads at least one real API-backed module or shows a scoped retry state.
- Database loads real anime subjects or shows a scoped retry state.
- Search waits briefly after typing before searching.
- Detail opens from at least one list.
- My shows unauthenticated future-login messaging.

- [ ] **Step 5: Commit and push**

```bash
git add MyBangumi MyBangumiTests MyBangumiUITests
git commit -m "Complete first Bangumi browsing slice"
git push
```

---

## Final Review Checklist

- Every tab required by the spec exists.
- No feature view performs `URLSession` work directly.
- Production networking goes through `BangumiAPIClient`.
- Tests and previews can use `MockBangumiAPI`.
- Search debounce is 400ms, within the required 300ms-500ms range.
- Remote images use `AsyncImage`.
- The project has no new package dependency.
- SwiftData is not enabled.
- The app builds after every task.
- Each completed task has a git commit.
