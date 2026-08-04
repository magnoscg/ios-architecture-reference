import ArchitectureData
import ArchitectureDomain
import ArchitectureFeature
import Foundation

public enum ArchitectureReference {
  @MainActor
  public static func demo() -> ArchitectureRootView {
    let repository = StaticArchitectureArticleRepository(articles: demoArticles)
    return ArchitectureRootView(
      loadArticles: LoadArchitectureArticles(repository: repository)
    )
  }

  @MainActor
  public static func live(baseURL: URL) -> ArchitectureRootView {
    let repository = RemoteArchitectureArticleRepository(
      client: URLSessionHTTPClient(),
      endpoint: ArchitectureEndpoint(baseURL: baseURL)
    )
    return ArchitectureRootView(
      loadArticles: LoadArchitectureArticles(repository: repository)
    )
  }

  private static let demoArticles: [ArchitectureArticle] = [
    ArchitectureArticle(
      id: "dependency-direction",
      title: "Protect dependency direction",
      summary: "Domain owns the abstractions. Data and UI depend inward, never the reverse.",
      category: .boundaries,
      readingTimeMinutes: 4,
      takeaways: [
        "Keep the domain independent from Apple frameworks and transport details.",
        "Let concrete repositories satisfy protocols declared by the domain.",
        "Reject convenience imports that turn boundaries into cycles.",
      ]
    ),
    ArchitectureArticle(
      id: "main-actor-state",
      title: "Keep observable UI state on MainActor",
      summary:
        "View models publish synchronous, coherent states while async work remains injected and testable.",
      category: .state,
      readingTimeMinutes: 5,
      takeaways: [
        "Represent loading, content, empty and failure as explicit states.",
        "Use Sendable values when data crosses an isolation boundary.",
        "Do not add actors when immutable values and MainActor are enough.",
      ]
    ),
    ArchitectureArticle(
      id: "typed-navigation",
      title: "Route with typed values",
      summary:
        "A route enum and an observable router make navigation reviewable, testable and ready for deep links.",
      category: .navigation,
      readingTimeMinutes: 3,
      takeaways: [
        "Keep NavigationStack path ownership outside feature views.",
        "Pass domain identifiers or values instead of untyped strings.",
        "Test route mutations without rendering SwiftUI.",
      ]
    ),
    ArchitectureArticle(
      id: "composition-root",
      title: "Compose concrete dependencies once",
      summary: "The composition root is the only place that knows the complete object graph.",
      category: .delivery,
      readingTimeMinutes: 4,
      takeaways: [
        "Inject use cases instead of reaching for global singletons.",
        "Offer deterministic demo dependencies for previews and tests.",
        "Keep production configuration at the application boundary.",
      ]
    ),
  ]
}
