import Foundation

// MARK: - ArchitectureStaticDataSourceImpl

/// Implementation of ArchitectureStaticDataSource with embedded static data.
/// Contains all architecture features as hardcoded domain models.
struct ArchitectureStaticDataSourceImpl: ArchitectureStaticDataSource {
    // MARK: - Public Methods

    func getFeatures() -> [ArchitectureModel] {
        Self.architectureFeatures
    }

    func getFeature(id: String) -> ArchitectureModel? {
        Self.architectureFeatures.first { $0.id == id }
    }
}

// MARK: - Static Data

private extension ArchitectureStaticDataSourceImpl {
    // MARK: - Architecture Features Data

    static let architectureFeatures: [ArchitectureModel] = [ArchitectureModel(id: "clean-architecture",
                                                                              name: "Clean Architecture-inspired Layers",
                                                                              description: "Single app target with Domain, Data, and feature presentation layers separated by convention",
                                                                              category: .architecture,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "mvvm",
                                                                              name: "MVVM Pattern",
                                                                              description: "SwiftUI views driven by @Observable, @MainActor view models",
                                                                              category: .architecture,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "router-pattern",
                                                                              name: "Typed Router Pattern",
                                                                              description: "Feature route enums delegate to an app-level NavigationPath router",
                                                                              category: .architecture,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "dependency-injection",
                                                                              name: "Hierarchical Dependency Injection",
                                                                              description: "App dependencies and feature factories compose the object graph manually",
                                                                              category: .architecture,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "feature-based",
                                                                              name: "Layered + Feature Organization",
                                                                              description: "Domain and Data are grouped by feature; presentation owns DI, UI, state, mapping, and navigation",
                                                                              category: .architecture,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),

                                                            ArchitectureModel(id: "swiftui",
                                                                              name: "SwiftUI",
                                                                              description: "Declarative views backed by state-driven rendering",
                                                                              category: .ui,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "observable",
                                                                              name: "@Observable",
                                                                              description: "Observation-based view models isolated to the main actor",
                                                                              category: .ui,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "design-tokens",
                                                                              name: "Design System Tokens",
                                                                              description: "Centralized adaptive colors, typography, icon sizes, and spacing",
                                                                              category: .ui,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "view-modifiers",
                                                                              name: "Reusable ViewModifiers",
                                                                              description: "Shared list, card, button, and animation modifiers with accessibility fallbacks",
                                                                              category: .ui,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "state-separation",
                                                                              name: "Explicit View State",
                                                                              description: "Each feature keeps idle, loading, loaded, and error state outside its view model",
                                                                              category: .ui,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),

                                                            ArchitectureModel(id: "api-client",
                                                                              name: "Centralized APIClient",
                                                                              description: "Injected async HTTP client with generic decoding and interceptor execution",
                                                                              category: .networking,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "endpoint-builder",
                                                                              name: "Endpoint Builders",
                                                                              description: "Environment-backed Endpoint values and self-contained APIEndpoint implementations",
                                                                              category: .networking,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "typed-errors",
                                                                              name: "Typed API Errors",
                                                                              description: "APIError distinguishes network, HTTP, decoding, invalid URL, and unknown failures",
                                                                              category: .networking,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "error-mapping",
                                                                              name: "Error Layer Mapping",
                                                                              description: "Use cases map API failures to DomainError; view models map them to ErrorDecorator",
                                                                              category: .networking,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "pokemon-api",
                                                                              name: "PokeAPI Example",
                                                                              description: "Working paginated list and detail flow backed by PokeAPI",
                                                                              category: .networking,
                                                                              isImplemented: true,
                                                                              systemIcon: "globe"),

                                                            ArchitectureModel(id: "ssl-pinning",
                                                                              name: "SSL Public Key Pinning",
                                                                              description: "Optional URLSession public-key hash validation driven by environment configuration",
                                                                              category: .security,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "environment-config",
                                                                              name: "Environment Configuration",
                                                                              description: "Development, staging, and production values flow from xcconfig through Info.plist",
                                                                              category: .security,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),

                                                            ArchitectureModel(id: "swift-testing",
                                                                              name: "Swift Testing",
                                                                              description: "Unit tests use @Suite, @Test, #expect, and parameterized cases",
                                                                              category: .testing,
                                                                              isImplemented: true,
                                                                              systemIcon: nil),
                                                            ArchitectureModel(id: "testable-arch",
                                                                              name: "Protocol-based Testability",
                                                                              description: "Injected protocols and focused mocks isolate repositories, use cases, routers, and mappers",
                                                                              category: .testing,
                                                                              isImplemented: true,
                                                                              systemIcon: nil)]
}
