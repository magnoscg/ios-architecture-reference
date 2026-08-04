import Foundation

public struct ArchitectureEndpoint: Sendable {
  private let baseURL: URL

  public init(baseURL: URL) {
    self.baseURL = baseURL
  }

  public func request() throws -> URLRequest {
    guard baseURL.scheme?.lowercased() == "https" else {
      throw ArchitectureDataError.insecureTransport
    }

    let url =
      baseURL
      .appending(path: "architecture")
      .appending(path: "articles.json")
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 15
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    return request
  }
}
