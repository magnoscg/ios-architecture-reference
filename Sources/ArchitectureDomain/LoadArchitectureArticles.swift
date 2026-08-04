public enum ArchitectureDomainError: Error, Equatable, Sendable {
  case duplicateIdentifier(String)
}

public struct LoadArchitectureArticles: Sendable {
  private let repository: any ArchitectureArticleRepository

  public init(repository: any ArchitectureArticleRepository) {
    self.repository = repository
  }

  public func callAsFunction() async throws -> [ArchitectureArticle] {
    let articles = try await repository.fetchArticles()
    var identifiers = Set<String>()

    for article in articles where !identifiers.insert(article.id).inserted {
      throw ArchitectureDomainError.duplicateIdentifier(article.id)
    }

    return articles
  }
}
