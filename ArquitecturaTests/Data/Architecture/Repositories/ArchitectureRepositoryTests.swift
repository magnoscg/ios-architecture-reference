import Foundation
import Testing
@testable import Arquitectura

// MARK: - ArchitectureRepositoryTests

@Suite
struct ArchitectureRepositoryTests {
    // MARK: - Helper

    private func makeRepository() -> ArchitectureRepository {
        let staticDataSource = ArchitectureStaticDataSourceImpl()
        return ArchitectureRepositoryImpl(staticDataSource: staticDataSource)
    }

    // MARK: - Tests

    @Test("GetFeatures returns the factual architecture catalog")
    func getFeaturesReturnsAllFeatures() async throws {
        // Given
        let repository = makeRepository()

        // When
        let features = try await repository.getFeatures()
        let remoteFeatures = try await ArchitectureRemoteDataSourceImpl().fetchFeatures()

        // Then
        let allFeaturesAreImplemented = features.allSatisfy(\.isImplemented)
        let featureIds = Set(features.map(\.id))
        let remoteFeatureIds = Set(remoteFeatures.map(\.id))
        let featureClaims = features.map {
            [$0.id, $0.name, $0.description, $0.category.rawValue.lowercased(), String($0.isImplemented)]
                .joined(separator: "|")
        }.sorted()
        let remoteFeatureClaims = remoteFeatures.map {
            [$0.id, $0.name, $0.description, $0.category.lowercased(), String($0.isImplemented)]
                .joined(separator: "|")
        }.sorted()

        #expect(features.count == 19)
        #expect(allFeaturesAreImplemented)
        #expect(featureIds == remoteFeatureIds)
        #expect(featureClaims == remoteFeatureClaims)

        let pokemon = try #require(features.first { $0.id == "pokemon-api" })
        #expect(pokemon.systemIcon == "globe")

        let swiftTesting = try #require(features.first { $0.id == "swift-testing" })
        #expect(swiftTesting.isImplemented)
    }

    @Test("GetFeatures returns features with valid categories")
    func getFeaturesReturnsValidCategories() async throws {
        // Given
        let repository = makeRepository()

        // When
        let features = try await repository.getFeatures()

        // Then
        let categories = Set(features.map(\.category))
        #expect(categories.count >= 3) // At least 3 different categories
    }

    @Test("GetFeatures returns features with unique IDs")
    func getFeaturesReturnsUniqueIds() async throws {
        // Given
        let repository = makeRepository()

        // When
        let features = try await repository.getFeatures()

        // Then
        let ids = features.map(\.id)
        let uniqueIds = Set(ids)
        #expect(ids.count == uniqueIds.count)
    }

    @Test("GetFeatures excludes architecture that is not implemented")
    func getFeaturesExcludesUnimplementedConcepts() async throws {
        // Given
        let repository = makeRepository()

        // When
        let features = try await repository.getFeatures()

        // Then
        let ids = Set(features.map(\.id))
        let allFeaturesAreImplemented = features.allSatisfy(\.isImplemented)

        #expect(!ids.contains("swiftdata"))
        #expect(!ids.contains("background-executor"))
        #expect(allFeaturesAreImplemented)
    }

    @Test("Repository correctly maps DTOs to domain models")
    func repositoryMapsCorrectly() async throws {
        // Given
        let repository = makeRepository()

        // When
        let features = try await repository.getFeatures()

        // Then
        // Verify at least one feature has all required properties
        let firstFeature = try #require(features.first)
        #expect(!firstFeature.id.isEmpty)
        #expect(!firstFeature.name.isEmpty)
        #expect(!firstFeature.description.isEmpty)
    }
}
