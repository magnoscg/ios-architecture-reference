import ArchitectureDomain
import Foundation
import Observation

@MainActor
@Observable
public final class ArchitectureArticleListViewModel {
  public private(set) var state: ArchitectureArticleListState = .idle
  public var searchText = ""

  private let loadArticles: LoadArchitectureArticles
  private let router: any ArchitectureRouting

  public init(
    loadArticles: LoadArchitectureArticles,
    router: any ArchitectureRouting
  ) {
    self.loadArticles = loadArticles
    self.router = router
  }

  public var visibleArticles: [ArchitectureArticle] {
    guard case .content(let articles) = state else { return [] }
    guard !searchText.isEmpty else { return articles }

    return articles.filter { article in
      article.title.localizedStandardContains(searchText)
        || article.summary.localizedStandardContains(searchText)
        || article.category.rawValue.localizedStandardContains(searchText)
    }
  }

  public func load(force: Bool = false) async {
    if !force, case .content = state {
      return
    }

    state = .loading

    do {
      let articles = try await loadArticles()
      try Task.checkCancellation()
      state = articles.isEmpty ? .empty : .content(articles)
    } catch is CancellationError {
      state = .idle
    } catch {
      state = .failure(
        message: "The architecture reference could not be loaded. Please try again."
      )
    }
  }

  public func retry() {
    Task { [weak self] in
      await self?.load(force: true)
    }
  }

  public func select(_ article: ArchitectureArticle) {
    router.show(article)
  }
}
