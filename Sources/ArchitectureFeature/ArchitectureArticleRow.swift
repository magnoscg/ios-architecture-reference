import ArchitectureDomain
import SwiftUI

struct ArchitectureArticleRow: View {
  let article: ArchitectureArticle

  var body: some View {
    HStack(alignment: .top, spacing: ArchitectureSpacing.medium) {
      Image(systemName: article.category.symbolName)
        .font(.title3)
        .foregroundStyle(Color.architectureAccent)
        .frame(width: 28, height: 28)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: ArchitectureSpacing.small) {
        Text(article.category.displayTitle.uppercased())
          .font(.caption2.monospaced().weight(.semibold))
          .foregroundStyle(Color.architectureAccent)

        Text(article.title)
          .font(.headline)
          .foregroundStyle(.primary)

        Text(article.summary)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(3)

        Label(
          "\(article.readingTimeMinutes) min",
          systemImage: "clock"
        )
        .font(.caption)
        .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical, ArchitectureSpacing.extraSmall)
    .contentShape(.rect)
  }
}
