public protocol ArchitectureArticleRepository: Sendable {
  func fetchArticles() async throws -> [ArchitectureArticle]
}
