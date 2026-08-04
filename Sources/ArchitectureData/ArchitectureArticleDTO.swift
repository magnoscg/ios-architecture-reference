import ArchitectureDomain
import Foundation

struct ArchitectureArticleDTO: Decodable, Sendable {
  let id: String
  let title: String
  let summary: String
  let category: String
  let readingTimeMinutes: Int
  let takeaways: [String]
}

enum ArchitectureArticleMapper {
  static func map(_ dto: ArchitectureArticleDTO) throws -> ArchitectureArticle {
    let id = dto.id.trimmingCharacters(in: .whitespacesAndNewlines)
    let title = dto.title.trimmingCharacters(in: .whitespacesAndNewlines)
    let summary = dto.summary.trimmingCharacters(in: .whitespacesAndNewlines)

    guard
      !id.isEmpty,
      !title.isEmpty,
      !summary.isEmpty,
      (1...60).contains(dto.readingTimeMinutes),
      let category = ArchitectureCategory(rawValue: dto.category)
    else {
      throw ArchitectureDataError.invalidPayload
    }

    return ArchitectureArticle(
      id: id,
      title: title,
      summary: summary,
      category: category,
      readingTimeMinutes: dto.readingTimeMinutes,
      takeaways: dto.takeaways
    )
  }
}
