import ArchitectureDomain
import SwiftUI

public struct ArchitectureArticleDetailView: View {
  private let article: ArchitectureArticle

  public init(article: ArchitectureArticle) {
    self.article = article
  }

  public var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: ArchitectureSpacing.large) {
        Label(article.category.displayTitle, systemImage: article.category.symbolName)
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(Color.architectureAccent)

        Text(article.title)
          .font(.largeTitle.bold())

        Text(article.summary)
          .font(.title3)
          .foregroundStyle(.secondary)

        Divider()

        Text("Key takeaways")
          .font(.headline)

        ForEach(article.takeaways, id: \.self) { takeaway in
          Label(takeaway, systemImage: "checkmark.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.primary)
        }
      }
      .frame(maxWidth: 680, alignment: .leading)
      .padding(ArchitectureSpacing.large)
    }
    .navigationTitle(article.category.displayTitle)
  }
}
