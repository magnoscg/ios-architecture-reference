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

    // MARK: - Cache Tests

    @Test("Cached data returns same result on multiple calls")
    func loadFeatureDetailsReturnsSameResultOnMultipleCalls() throws {
        // Given: Two consecutive calls
        let firstResult = try sut.loadFeatureDetails()
        let secondResult = try sut.loadFeatureDetails()

        // Then: Both return the same data without re-reading disk
        #expect(firstResult.count == secondResult.count)
        #expect(firstResult.map(\.id) == secondResult.map(\.id))
    }

    @Test("loadFeatureDetail returns correct item by ID")
    func loadFeatureDetailReturnsCorrectItem() throws {
        // Given: All features loaded
        let allFeatures = try sut.loadFeatureDetails()
        guard let firstFeature = allFeatures.first else {
            Issue.record("No features loaded from JSON")
            return
        }

        // When: Loading by specific ID
        let result = try sut.loadFeatureDetail(id: firstFeature.id)

        // Then: Returns the matching feature
        #expect(result?.id == firstFeature.id)
    }

    @Test("loadFeatureDetail returns nil for unknown ID")
    func loadFeatureDetailReturnsNilForUnknownId() throws {
        let result = try sut.loadFeatureDetail(id: "nonexistent-feature-id")
        #expect(result == nil)
    }

    @Test("Cached features match the factual architecture catalog")
    func cachedFeaturesAreNotEmpty() throws {
        let features = try sut.loadFeatureDetails()
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
}
