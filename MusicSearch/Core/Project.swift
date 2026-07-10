import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Core",
    packages: ProjectEnvironment.packages,
    settings: ProjectEnvironment.projectSettings,
    targets: [
        .target(
            name: "MSDesignSystem",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSDesignSystem",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["DesignSystem/**"],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSUtil",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSUtil",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Util/**"],
            dependencies: [
                .package(product: "Kingfisher")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSDomain",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSDomain",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: [
                "Domain/Entities/**",
                "Domain/Interfaces/**",
                "Domain/Services/**",
                "Domain/UseCases/**",
                "Domain/Sources/**"
            ],
            dependencies: [
                .target(name: "MSUtil")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSData",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSData",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: [
                "Data/DTOs/**",
                "Data/Network/**",
                "Data/Repositories/**",
                "Infrastructure/**"
            ],
            dependencies: [
                .target(name: "MSDomain"),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .package(product: "NetworkLayer")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSDomainTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSDomainTests",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Domain/Tests/**"],
            dependencies: [
                .target(name: "MSDomain")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSDataTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSDataTests",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Data/Tests/**"],
            dependencies: [
                .target(name: "MSData"),
                .target(name: "MSDomain")
            ],
            settings: ProjectEnvironment.projectSettings
        )
    ]
)
