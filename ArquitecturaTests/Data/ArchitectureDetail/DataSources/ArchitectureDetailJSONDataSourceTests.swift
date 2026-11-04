import Foundation
import Testing
@testable import Arquitectura

// MARK: - ArchitectureDetailJSONDataSourceTests

@Suite
@MainActor
struct ArchitectureDetailJSONDataSourceTests {
    // MARK: - Properties

    private let sut: ArchitectureDetailJSONDataSourceImpl

    // MARK: - Init

    init() {
        sut = ArchitectureDetailJSONDataSourceImpl()
    }

    // MARK: - Bundled File Tests

    @Test("loadFeatureDetail returns correct item by ID")
    func loadFeatureDetailReturnsCorrectItem() async throws {
        let allFeatures = try await sut.loadFeatureDetails()
        let firstFeature = try #require(allFeatures.first)

        let result = try await sut.loadFeatureDetail(id: firstFeature.id)

        #expect(result?.id == firstFeature.id)
    }

    @Test("loadFeatureDetail returns nil for unknown ID")
    func loadFeatureDetailReturnsNilForUnknownId() async throws {
        let result = try await sut.loadFeatureDetail(id: "nonexistent-feature-id")

        #expect(result == nil)
    }

    @Test("Bundled features match the factual architecture catalog")
    func bundledFeaturesMatchCatalog() async throws {
        let features = try await sut.loadFeatureDetails()
        let ids = Set(features.map(\.id))
        let catalogIds = Set(ArchitectureStaticDataSourceImpl().getFeatures().map(\.id))
        let allFeaturesAreImplemented = features.allSatisfy(\.isImplemented)
        let hasLegacyFileName = features.contains { feature in
            feature.filesInvolved.contains { $0.name.contains("Article") }
        }
        let hasLegacyCodeExample = features.contains { feature in
            feature.codeExample?.code.contains("Article") == true
        }

        #expect(features.count == 19)
        #expect(ids.count == features.count)
        #expect(ids == catalogIds)
        #expect(!ids.contains("swiftdata"))
        #expect(!ids.contains("background-executor"))
        #expect(allFeaturesAreImplemented)
        #expect(!hasLegacyFileName)
        #expect(!hasLegacyCodeExample)
    }

    // MARK: - Failure Tests

    @Test("Missing file throws fileNotFound instead of returning an empty list")
    func missingFileThrowsFileNotFound() async {
        let dataSource = ArchitectureDetailJSONDataSourceImpl(fileURL: nil)

        await #expect(throws: DataSourceError.self) {
            try await dataSource.loadFeatureDetails()
        }
    }

    @Test("Invalid JSON throws a DecodingError instead of returning an empty list")
    func invalidJSONThrowsDecodingError() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appending(path: "invalid-architecture-details-\(UUID().uuidString).json")
        try Data("not valid json".utf8).write(to: fileURL)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        let dataSource = ArchitectureDetailJSONDataSourceImpl(fileURL: fileURL)

        await #expect(throws: DecodingError.self) {
            try await dataSource.loadFeatureDetail(id: "any")
        }
    }
}
