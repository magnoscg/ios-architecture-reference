import Foundation
import Testing

@testable import ArchitectureData

@Suite("Architecture endpoint")
struct ArchitectureEndpointTests {
  @Test("builds a deterministic HTTPS request")
  func buildsHTTPSRequest() throws {
    let subject = ArchitectureEndpoint(baseURL: URL(string: "https://example.com/api")!)

    let request = try subject.request()

    #expect(request.url?.absoluteString == "https://example.com/api/architecture/articles.json")
    #expect(request.httpMethod == "GET")
    #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    #expect(request.timeoutInterval == 15)
  }

  @Test("rejects clear-text transport before making a request")
  func rejectsClearTextTransport() {
    let subject = ArchitectureEndpoint(baseURL: URL(string: "http://example.com")!)

    #expect(throws: ArchitectureDataError.insecureTransport) {
      try subject.request()
    }
  }
}
