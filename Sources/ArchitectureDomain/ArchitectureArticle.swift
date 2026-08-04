import Foundation

public struct ArchitectureArticle: Identifiable, Hashable, Sendable {
  public let id: String
  public let title: String
  public let summary: String
  public let category: ArchitectureCategory
  public let readingTimeMinutes: Int
  public let takeaways: [String]

  public init(
    id: String,
    title: String,
    summary: String,
    category: ArchitectureCategory,
    readingTimeMinutes: Int,
    takeaways: [String]
  ) {
    self.id = id
    self.title = title
    self.summary = summary
    self.category = category
    self.readingTimeMinutes = readingTimeMinutes
    self.takeaways = takeaways
  }
}

public enum ArchitectureCategory: String, CaseIterable, Codable, Hashable, Sendable {
  case boundaries
  case state
  case navigation
  case delivery
}
