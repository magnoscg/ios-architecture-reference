import SwiftUI

// MARK: - ArchitectureDetailView

/// Detail view for displaying feature information
struct ArchitectureDetailView: View {
    // MARK: - Properties

    @State
    private var viewModel: ArchitectureDetailViewModel

    @State
    private var retryTrigger = false

    // MARK: - Init

    init(viewModel: ArchitectureDetailViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                loadingView

            case let .loaded(decorator):
                loadedView(decorator: decorator)

            case let .error(error):
                errorView(error: error)
            }
        }
        .navigationTitle(String(localized: "detail.navigation.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .task(id: retryTrigger) {
            await viewModel.loadFeature()
        }
    }
}

// MARK: - Private Views

private extension ArchitectureDetailView {
    var loadingView: some View {
        LoadingStateView()
    }

    func loadedView(decorator: ArchitectureDetailDecorator) -> some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: Spacing.lg) {
                DetailHeroHeader(decorator: decorator)

                if !decorator.filesInvolved.isEmpty {
                    FilesInvolvedSection(files: decorator.filesInvolved)
                }

                ImplementationDetailsCard(details: decorator.implementationDetails,
                                          codeExample: decorator.codeExample)
                    .padding(.horizontal, Spacing.md)

                if !decorator.bestPractices.isEmpty {
                    BestPracticesSection(bestPractices: decorator.bestPractices)
                        .padding(.horizontal, Spacing.md)
                }

                if decorator.showsTryItButton {
                    tryItButton
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, Spacing.xl)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(AppColors.background)
    }

    var tryItButton: some View {
        Button {
            viewModel.navigateToPokemonList()
        } label: {
            Label(String(localized: "detail.tryIt.button"), systemImage: "play.circle.fill")
                .font(AppTypography.headline.font)
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)
                .background(AppColors.accent)
                .foregroundStyle(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, Spacing.md)
    }

    func errorView(error: ErrorDecorator) -> some View {
        ErrorView(error: error) {
            retryTrigger.toggle()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ArchitectureDetailView(viewModel: ArchitectureDetailViewModel(featureId: "clean-architecture",
                                                                      useCase: PreviewDetailUseCase(),
                                                                      router: PreviewArchitectureDetailRouter(),
                                                                      decoratorMapper: ArchitectureDetailDecoratorMapperImpl()))
    }
}

// MARK: - Preview Helpers

private struct PreviewDetailUseCase: ArchitectureDetailUseCase {
    func execute(id: String) async throws -> ArchitectureDetailModel? {
        ArchitectureDetailModel(id: id,
                                name: "Clean Architecture-inspired Layers",
                                icon: "building.2.crop.circle.fill",
                                version: nil,
                                category: .architecture,
                                subtitle: "Architecture & Structure",
                                isImplemented: true,
                                filesInvolved: [.init(name: "ArchitectureModel.swift", icon: "doc.text.fill"),
                                                .init(name: "ArchitectureRepository.swift",
                                                      icon: "cylinder.split.1x2.fill"),
                                                .init(name: "ArchitectureUseCaseImpl.swift", icon: "gearshape.fill")],
                                implementationDetails: "The app uses logical Domain, Data, and feature-presentation layers inside one application target. Folder boundaries are conventions rather than compile-time module boundaries.",
                                codeExample: .init(language: "swift",
                                                   code: "protocol ArchitectureUseCase: Sendable {\n    func execute() async throws -> [ArchitectureModel]\n}"),
                                bestPractices: [.init(id: "logical-boundaries", title: "Honest boundaries",
                                                      description: "The folders communicate dependency direction; the single app target does not enforce it.")])
    }
}

@MainActor
private struct PreviewArchitectureDetailRouter: ArchitectureDetailRouter {
    func navigateToPokemonList() {}
    func goBack() {}
}
