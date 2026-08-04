import ArchitectureDomain
import SwiftUI

public struct ArchitectureRootView: View {
  @State private var router: ArchitectureRouter
  @State private var viewModel: ArchitectureArticleListViewModel

  @MainActor
  public init(loadArticles: LoadArchitectureArticles) {
    let router = ArchitectureRouter()
    _router = State(initialValue: router)
    _viewModel = State(
      initialValue: ArchitectureArticleListViewModel(
        loadArticles: loadArticles,
        router: router
      )
    )
  }

  public var body: some View {
    NavigationStack(path: $router.path) {
      ArchitectureArticleListView(viewModel: viewModel)
        .navigationDestination(for: ArchitectureRoute.self) { route in
          switch route {
          case .article(let article):
            ArchitectureArticleDetailView(article: article)
          }
        }
    }
    .tint(Color.architectureAccent)
  }
}
