public enum ArchitectureDataError: Error, Equatable, Sendable {
  case insecureTransport
  case invalidResponse
  case unexpectedStatusCode(Int)
  case invalidPayload
}
