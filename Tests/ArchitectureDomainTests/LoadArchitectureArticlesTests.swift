import Testing

@testable import ArchitectureDomain

@Suite("Load architecture articles")
struct LoadArchitectureArticlesTests {
  @Test("returns unique articles without changing repository order")
  func returnsUniqueArticles() async throws {
    let articles = [Self.article(id: "first"), Self.article(id: "second")]
    let subject = LoadArchitectureArticles(
      repository: StubArticleRepository(result: .success(articles))
    )

    let result = try await subject()

    #expect(result == articles)
  }

  @Test("rejects duplicate domain identifiers")
  func rejectsDuplicateIdentifiers() async {
    let articles = [Self.article(id: "duplicate"), Self.article(id: "duplicate")]
    let subject = LoadArchitectureArticles(
      repository: StubArticleRepository(result: .success(articles))
    )

    await #expect(
      throws: ArchitectureDomainError.duplicateIdentifier("duplicate")
    ) {
      try await subject()
    }
  }

  @Test("propagates repository failures")
  func propagatesRepositoryFailure() async {
    let subject = LoadArchitectureArticles(
      repository: StubArticleRepository(result: .failure(.unavailable))
    )

    await #expect(throws: StubArticleRepository.Error.unavailable) {
      try await subject()
    }
  }

  private static func article(id: String) -> ArchitectureArticle {
    ArchitectureArticle(
      id: id,
      title: id,
      summary: "Summary",
      category: .boundaries,
      readingTimeMinutes: 3,
      takeaways: ["One"]
    )
  }
}

private struct StubArticleRepository: ArchitectureArticleRepository {
  enum Error: Swift.Error, Sendable {
    case unavailable
  }

  let result: Result<[ArchitectureArticle], Error>

  func fetchArticles() async throws -> [ArchitectureArticle] {
    try result.get()
  }
}
