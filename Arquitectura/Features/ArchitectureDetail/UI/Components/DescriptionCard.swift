import SwiftUI

// MARK: - DescriptionCard

/// Card component for displaying description text with a section label.
struct DescriptionCard: View {
    // MARK: - Properties

    let title: String
    let description: String

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(AppTypography.caption1.font)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)

            Text(description)
                .font(AppTypography.body.font)
                .foregroundStyle(AppColors.text)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }
}

// MARK: - Private Views

private extension DescriptionCard {
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppColors.cardBackground)
            .overlay(RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Preview

#Preview {
    DescriptionCard(title: "Description",
                    description: "The app uses logical Domain, Data, and feature-presentation layers inside one application target. Folder boundaries are conventions rather than compile-time module boundaries.")
        .padding()
        .background(AppColors.background)
}
