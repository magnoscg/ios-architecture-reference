import ArchitectureDomain

public struct StaticArchitectureArticleRepository: ArchitectureArticleRepository {
  private let articles: [ArchitectureArticle]

  public init(articles: [ArchitectureArticle]) {
    self.articles = articles
  }

  public func fetchArticles() async throws -> [ArchitectureArticle] {
    articles
  }
}
