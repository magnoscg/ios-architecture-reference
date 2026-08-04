import ArchitectureDomain
import SwiftUI

public struct ArchitectureArticleListView: View {
  @Bindable private var viewModel: ArchitectureArticleListViewModel

  public init(viewModel: ArchitectureArticleListViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    Group {
      switch viewModel.state {
      case .idle, .loading:
        ProgressView("Loading reference…")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      case .content:
        content
      case .empty:
        ContentUnavailableView(
          "No articles",
          systemImage: "doc.text.magnifyingglass",
          description: Text("The repository returned an empty reference.")
        )
      case .failure(let message):
        ContentUnavailableView {
          Label("Unable to load", systemImage: "exclamationmark.triangle")
        } description: {
          Text(message)
        } actions: {
          Button("Try Again") {
            viewModel.retry()
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
    .navigationTitle("Architecture")
    .searchable(text: $viewModel.searchText, prompt: "Search the reference")
    .task {
      await viewModel.load()
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.visibleArticles.isEmpty, !viewModel.searchText.isEmpty {
      ContentUnavailableView.search(text: viewModel.searchText)
    } else {
      List(viewModel.visibleArticles) { article in
        Button {
          viewModel.select(article)
        } label: {
          ArchitectureArticleRow(article: article)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(article.title), \(article.category.displayTitle)")
      }
      .listStyle(.plain)
      .refreshable {
        await viewModel.load(force: true)
      }
    }
  }
}
