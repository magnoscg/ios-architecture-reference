import ArchitectureDomain

public enum ArchitectureArticleListState: Equatable, Sendable {
  case idle
  case loading
  case content([ArchitectureArticle])
  case empty
  case failure(message: String)
}
