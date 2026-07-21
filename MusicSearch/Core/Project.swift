import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Core",
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
                .external(name: "Kingfisher")
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
                "Domain/Sources/**",
                "Domain/Util/**"
            ],
            dependencies: [
                .target(name: "MSUtil")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSInfrastructure",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSInfrastructure",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: [
                .glob("Infrastructure/**", excluding: ["Infrastructure/**/Tests/**"])
            ],
            dependencies: [
                .target(name: "MSDomain"),
                .external(name: "NetworkLayer")
            ,
                .project(target: "ArchiveDomain", path: "../Features/Archive")],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSInfrastructureTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSInfrastructureTests",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Infrastructure/**/Tests/**"],
            dependencies: [
                .target(name: "MSInfrastructure"),
                .target(name: "MSDomain"),
                .target(name: "MSTesting"),
                .target(name: "MSUtil"),
                .project(target: "ArchiveDomain", path: "../Features/Archive")
            ],
            settings: ProjectEnvironment.projectSettings
        ),
        .target(
            name: "MSTesting",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MSTesting",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Testing/Sources/**"],
            dependencies: [
                .target(name: "MSDomain"),
                .external(name: "NetworkLayer")
            ],
            settings: ProjectEnvironment.projectSettings
        )
    ]
)
