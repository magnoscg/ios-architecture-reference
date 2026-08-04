import ArchitectureDomain
import Testing

@testable import ArchitectureData

@Suite("Architecture article mapper")
struct ArchitectureArticleMapperTests {
  @Test("maps a valid transport object into the domain")
  func mapsValidPayload() throws {
    let dto = ArchitectureArticleDTO(
      id: " boundaries ",
      title: " Dependency direction ",
      summary: " Keep dependencies pointing inward. ",
      category: "boundaries",
      readingTimeMinutes: 4,
      takeaways: ["Own abstractions in the domain"]
    )

    let article = try ArchitectureArticleMapper.map(dto)

    #expect(article.id == "boundaries")
    #expect(article.title == "Dependency direction")
    #expect(article.category == .boundaries)
    #expect(article.readingTimeMinutes == 4)
  }

  @Test(
    "rejects malformed payloads",
    arguments: [
      ArchitectureArticleDTO(
        id: "",
        title: "Title",
        summary: "Summary",
        category: "boundaries",
        readingTimeMinutes: 4,
        takeaways: []
      ),
      ArchitectureArticleDTO(
        id: "id",
        title: "Title",
        summary: "Summary",
        category: "unknown",
        readingTimeMinutes: 4,
        takeaways: []
      ),
      ArchitectureArticleDTO(
        id: "id",
        title: "Title",
        summary: "Summary",
        category: "state",
        readingTimeMinutes: 0,
        takeaways: []
      ),
    ]
  )
  func rejectsMalformedPayload(_ dto: ArchitectureArticleDTO) {
    #expect(throws: ArchitectureDataError.invalidPayload) {
      try ArchitectureArticleMapper.map(dto)
    }
  }
}
