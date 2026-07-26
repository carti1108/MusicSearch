import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Archive",
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "Archive",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .external(name: "ComposableArchitecture")
            ],
            basePath: "Shared"
        )],
        [.target(
            name: "ArchiveSharedPresentation",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).ArchiveSharedPresentation",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Shared/Presentation/Sources/**"],
            dependencies: [
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            settings: ProjectEnvironment.projectSettings
        )],
        [.target(
            name: "ArchiveSharedTesting",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(ProjectEnvironment.bundlePrefix).ArchiveSharedTesting",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .default,
            sources: ["Shared/Testing/Sources/**"],
            dependencies: [
                .target(name: "ArchiveDomain")
            ],
            settings: ProjectEnvironment.projectSettings
        )],
        [Target.dataTargets(
            name: "Archive",
            dependencies: [
                .target(name: "ArchiveDomain"),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "Archive",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .target(name: "FeatureAddArchiveInterface"),
                .target(name: "FeatureArchiveSearchInterface"),
                .target(name: "FeatureArchiveFolderInterface"),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .project(target: "FeatureSettingsInterface", path: .relativeToRoot("MusicSearch/Features/Settings")),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .external(name: "MicroRIBs"),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureAddArchiveInterface"),
                .target(name: "FeatureArchiveSearchInterface"),
                .target(name: "FeatureArchiveFolderInterface"),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .project(target: "FeatureSettingsInterface", path: .relativeToRoot("MusicSearch/Features/Settings")),
                .target(name: "FeatureAddArchive"),
                .target(name: "FeatureArchiveSearch"),
                .target(name: "FeatureArchiveFolder"),
                .target(name: "FeatureArchiveFolderDetail"),
                .target(name: "FeatureArchiveTrackSearch"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "ArchiveMain"
        ),
        Target.microFeatureTargets(
            name: "ArchiveFolderDetail",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .target(name: "ArchiveSharedPresentation"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "NetworkLayer"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "ArchiveFolderDetail"
        ),
        Target.microFeatureTargets(
            name: "AddArchive",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .target(name: "FeatureArchiveTrackSearchInterface"),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .target(name: "FeatureArchiveTrackSearchInterface"),
                .target(name: "FeatureArchiveTrackSearch"),
                .external(name: "NetworkLayer"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            exampleDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "AddArchive"
        ),
        Target.microFeatureTargets(
            name: "ArchiveFolder",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .target(name: "ArchiveSharedPresentation"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .external(name: "NetworkLayer"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "ArchiveFolder"
        ),
        Target.microFeatureTargets(
            name: "ArchiveSearch",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .external(name: "NetworkLayer"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "ArchiveSearch"
        ),
        Target.microFeatureTargets(
            name: "ArchiveTrackSearch",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            testsDependencies: [
                .target(name: "ArchiveSharedTesting"),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            folderName: "ArchiveTrackSearch"
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(name: "FeatureArchiveExample", buildAction: .buildAction(targets: ["FeatureArchiveExample"])),
        .scheme(name: "FeatureArchiveFolderDetailExample", buildAction: .buildAction(targets: ["FeatureArchiveFolderDetailExample"])),
        .scheme(name: "FeatureAddArchiveExample", buildAction: .buildAction(targets: ["FeatureAddArchiveExample"])),
        .scheme(name: "FeatureArchiveFolderExample", buildAction: .buildAction(targets: ["FeatureArchiveFolderExample"])),
        .scheme(name: "FeatureArchiveSearchExample", buildAction: .buildAction(targets: ["FeatureArchiveSearchExample"])),
        .scheme(name: "FeatureArchiveTrackSearchExample", buildAction: .buildAction(targets: ["FeatureArchiveTrackSearchExample"]))
    ]
)
