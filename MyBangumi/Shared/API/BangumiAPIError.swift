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
