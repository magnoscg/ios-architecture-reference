import SwiftUI

// MARK: - ArchitectureFeatureRow

/// Row component displaying a single architecture feature.
///
/// Conforms to `Equatable` to enable SwiftUI to efficiently skip re-renders
/// when the underlying data hasn't changed. Use with `EquatableView` wrapper
/// in ForEach for optimal list performance.
struct ArchitectureFeatureRow: View, Equatable {
    // MARK: - Properties

    let feature: ArchitectureItemDecorator

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            statusIcon

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(feature.name)
                    .font(AppTypography.headline.font)
                    .foregroundStyle(AppColors.text)

                Text(feature.description)
                    .font(AppTypography.subheadline.font)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(AppTypography.caption1.font)
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Private Views

private extension ArchitectureFeatureRow {
    var statusIcon: some View {
        feature.icon.image(size: IconSize.md, color: feature.statusColor.uiColor)
    }
}

// MARK: - Preview

#Preview {
    List {
        ArchitectureFeatureRow(feature: ArchitectureItemDecorator(id: "clean-architecture",
                                                                  name: "Clean Architecture-inspired Layers",
                                                                  description: "Single app target with Domain, Data, and feature presentation layers separated by convention",
                                                                  icon: .system("checkmark.circle.fill"),
                                                                  statusColor: .implemented))

        ArchitectureFeatureRow(feature: ArchitectureItemDecorator(id: "swift-testing",
                                                                  name: "Swift Testing",
                                                                  description: "Unit tests use @Suite, @Test, #expect, and parameterized cases",
                                                                  icon: .system("checkmark.circle.fill"),
                                                                  statusColor: .implemented))
    }
}
