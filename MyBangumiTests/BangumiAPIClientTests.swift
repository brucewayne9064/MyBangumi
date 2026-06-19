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

@Suite(.serialized)
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

    @Test func subjectUsesCacheForRepeatedDetailRequests() async throws {
        let client = makeClient()
        var requestCount = 0
        URLProtocolStub.handler = { request in
            requestCount += 1
            let data = """
            {
              "id": 42,
              "name": "Cowboy Bebop",
              "name_cn": "星际牛仔",
              "summary": "Space western",
              "images": { "large": "https://example.com/bebop.jpg" },
              "rating": { "score": 9.1, "total": 1000 },
              "rank": 1,
              "tags": [{ "name": "科幻" }],
              "infobox": [{ "key": "放送开始", "value": "1998-04-03" }]
            }
            """.data(using: .utf8)!
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, data)
        }

        let first = try await client.subject(id: 42)
        let second = try await client.subject(id: 42)

        #expect(first == second)
        #expect(requestCount == 1)
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
