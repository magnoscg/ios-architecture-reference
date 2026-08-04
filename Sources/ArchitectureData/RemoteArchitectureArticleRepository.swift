import ArchitectureDomain
import Foundation

public actor RemoteArchitectureArticleRepository: ArchitectureArticleRepository {
  private let client: any HTTPClient
  private let endpoint: ArchitectureEndpoint
  private let decoder: JSONDecoder

  public init(
    client: any HTTPClient,
    endpoint: ArchitectureEndpoint
  ) {
    self.client = client
    self.endpoint = endpoint
    decoder = JSONDecoder()
  }

  public func fetchArticles() async throws -> [ArchitectureArticle] {
    let request = try endpoint.request()
    let (data, response) = try await client.data(for: request)

    guard (200..<300).contains(response.statusCode) else {
      throw ArchitectureDataError.unexpectedStatusCode(response.statusCode)
    }

    let payload: [ArchitectureArticleDTO]
    do {
      payload = try decoder.decode([ArchitectureArticleDTO].self, from: data)
    } catch {
      throw ArchitectureDataError.invalidPayload
    }

    return try payload.map(ArchitectureArticleMapper.map)
  }
}
