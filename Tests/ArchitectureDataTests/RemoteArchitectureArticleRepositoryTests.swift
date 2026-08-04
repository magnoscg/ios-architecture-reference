import ArchitectureDomain
import Foundation
import Testing

@testable import ArchitectureData

@Suite("Remote architecture article repository")
struct RemoteArchitectureArticleRepositoryTests {
  @Test("decodes a successful response")
  func decodesSuccessfulResponse() async throws {
    let payload = Data(
      #"[{"id":"state","title":"State","summary":"Explicit states","category":"state","readingTimeMinutes":3,"takeaways":["One state"]}]"#
        .utf8
    )
    let response = try makeResponse(statusCode: 200)
    let client = StubHTTPClient { _ in (payload, response) }
    let subject = RemoteArchitectureArticleRepository(
      client: client,
      endpoint: ArchitectureEndpoint(baseURL: URL(string: "https://example.com")!)
    )

    let articles = try await subject.fetchArticles()

    let article = try #require(articles.first)
    #expect(article.id == "state")
    #expect(article.category == .state)
  }

  @Test("rejects non-success status codes")
  func rejectsNonSuccessStatus() async throws {
    let response = try makeResponse(statusCode: 503)
    let client = StubHTTPClient { _ in (Data(), response) }
    let subject = RemoteArchitectureArticleRepository(
      client: client,
      endpoint: ArchitectureEndpoint(baseURL: URL(string: "https://example.com")!)
    )

    await #expect(throws: ArchitectureDataError.unexpectedStatusCode(503)) {
      try await subject.fetchArticles()
    }
  }

  @Test("normalizes decoding errors into a stable data error")
  func normalizesDecodingErrors() async throws {
    let response = try makeResponse(statusCode: 200)
    let client = StubHTTPClient { _ in (Data("not-json".utf8), response) }
    let subject = RemoteArchitectureArticleRepository(
      client: client,
      endpoint: ArchitectureEndpoint(baseURL: URL(string: "https://example.com")!)
    )

    await #expect(throws: ArchitectureDataError.invalidPayload) {
      try await subject.fetchArticles()
    }
  }
}

private struct StubHTTPClient: HTTPClient {
  let handler: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

  init(
    handler: @escaping @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)
  ) {
    self.handler = handler
  }

  func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    try await handler(request)
  }
}

private func makeResponse(statusCode: Int) throws -> HTTPURLResponse {
  try #require(
    HTTPURLResponse(
      url: URL(string: "https://example.com/architecture/articles.json")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"]
    )
  )
}
