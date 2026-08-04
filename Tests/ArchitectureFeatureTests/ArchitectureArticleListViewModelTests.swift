import ArchitectureDomain
import Testing

@testable import ArchitectureFeature

@Suite("Architecture article list view model")
struct ArchitectureArticleListViewModelTests {
  @Test("publishes content after a successful load")
  @MainActor
  func publishesContent() async {
    let articles = [Self.article(id: "one", title: "Boundaries")]
    let subject = makeSubject(result: .success(articles)).subject

    await subject.load()

    #expect(subject.state == .content(articles))
  }

  @Test("publishes an explicit empty state")
  @MainActor
  func publishesEmptyState() async {
    let subject = makeSubject(result: .success([])).subject

    await subject.load()

    #expect(subject.state == .empty)
  }

  @Test("maps implementation failures to recruiter-safe copy")
  @MainActor
  func publishesStableFailureCopy() async {
    let subject = makeSubject(result: .failure(.unavailable)).subject

    await subject.load()

    #expect(
      subject.state
        == .failure(
          message: "The architecture reference could not be loaded. Please try again."
        )
    )
  }

  @Test("filters content with localized standard matching")
  @MainActor
  func filtersContent() async {
    let articles = [
      Self.article(id: "one", title: "Café architecture"),
      Self.article(id: "two", title: "Navigation"),
    ]
    let subject = makeSubject(result: .success(articles)).subject
    await subject.load()

    subject.searchText = "cafe"

    #expect(subject.visibleArticles.map(\.id) == ["one"])
  }

  @Test("delegates selection to the router")
  @MainActor
  func delegatesSelection() {
    let setup = makeSubject(result: .success([]))
    let article = Self.article(id: "route", title: "Typed routes")

    setup.subject.select(article)

    #expect(setup.router.selectedArticle == article)
  }

  @MainActor
  private func makeSubject(
    result: Result<[ArchitectureArticle], StubArticleRepository.Error>
  ) -> (subject: ArchitectureArticleListViewModel, router: SpyArchitectureRouter) {
    let router = SpyArchitectureRouter()
    let subject = ArchitectureArticleListViewModel(
      loadArticles: LoadArchitectureArticles(
        repository: StubArticleRepository(result: result)
      ),
      router: router
    )
    return (subject, router)
  }

  private static func article(id: String, title: String) -> ArchitectureArticle {
    ArchitectureArticle(
      id: id,
      title: title,
      summary: "A focused architecture note.",
      category: .boundaries,
      readingTimeMinutes: 3,
      takeaways: ["Keep the boundary explicit"]
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

@MainActor
private final class SpyArchitectureRouter: ArchitectureRouting {
  private(set) var selectedArticle: ArchitectureArticle?

  func show(_ article: ArchitectureArticle) {
    selectedArticle = article
  }

  func popToRoot() {}
}
