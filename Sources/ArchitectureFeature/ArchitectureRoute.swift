import ArchitectureDomain
import Observation

public enum ArchitectureRoute: Hashable, Sendable {
  case article(ArchitectureArticle)
}

@MainActor
public protocol ArchitectureRouting: AnyObject {
  func show(_ article: ArchitectureArticle)
  func popToRoot()
}

@MainActor
@Observable
public final class ArchitectureRouter: ArchitectureRouting {
  public var path: [ArchitectureRoute] = []

  public init() {}

  public func show(_ article: ArchitectureArticle) {
    path.append(.article(article))
  }

  public func popToRoot() {
    path.removeAll()
  }
}
