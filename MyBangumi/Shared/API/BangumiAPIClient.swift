import Foundation

struct BangumiAPIClient: BangumiAPI {
    private let baseURL: URL
    private let session: URLSession
    private let userAgent: String
    private let cache: InMemorySubjectCache
    private let accessTokenProvider: (@Sendable () -> String?)?

    init(
        baseURL: URL = URL(string: "https://api.bgm.tv")!,
        session: URLSession = .shared,
        userAgent: String = "MyBangumi/1.0 (iOS; https://github.com/brucewayne9064/MyBangumi)",
        cache: InMemorySubjectCache = InMemorySubjectCache(),
        accessTokenProvider: (@Sendable () -> String?)? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.userAgent = userAgent
        self.cache = cache
        self.accessTokenProvider = accessTokenProvider
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
        if let cached = await cache.detail(for: id) {
            return cached
        }
        let response: BangumiSubjectDTO = try await send(baseURL.appending(path: "/v0/subjects/\(id)"), method: "GET", body: Optional<Data>.none, endpoint: "/v0/subjects/{id}")
        let detail = response.detail
        await cache.store(detail)
        return detail
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
        if let accessToken = accessTokenProvider?(), !accessToken.isEmpty {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
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
