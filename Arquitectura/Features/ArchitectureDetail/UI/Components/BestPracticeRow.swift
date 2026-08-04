import SwiftUI

// MARK: - BestPracticeRow

/// Row displaying a single best practice with checkmark
struct BestPracticeRow: View {
    // MARK: - Properties

    let practice: BestPracticeDecorator

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            checkmarkIcon
            contentStack
            Spacer()
        }
    }
}

// MARK: - Private Views

private extension BestPracticeRow {
    var checkmarkIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.title3)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            .foregroundStyle(AppColors.success)
    }

    var contentStack: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(practice.title)
                .font(AppTypography.subheadline.font)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.text)

            Text(practice.description)
                .font(AppTypography.caption1.font)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        BestPracticeRow(practice: BestPracticeDecorator(id: "logical-boundaries",
                                                        title: "Honest boundaries",
                                                        description: "The folders communicate dependency direction; the single app target does not enforce it."))
        BestPracticeRow(practice: BestPracticeDecorator(id: "domain-models",
                                                        title: "Domain models",
                                                        description: "Networking DTOs are mapped before presentation consumes feature data."))
    }
    .padding()
}
