import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Archive",
    packages: ProjectEnvironment.packages,
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "Archive",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        [Target.dataTargets(
            name: "Archive",
            dependencies: [
                .target(name: "ArchiveDomain"),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core"))
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
                .package(product: "MicroRIBs")
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
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
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
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "NetworkLayer"),
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
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
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .package(product: "NetworkLayer"),
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchTesting", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "AddArchive"
        ),
        Target.microFeatureTargets(
            name: "ArchiveFolder",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .package(product: "NetworkLayer"),
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
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
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureArchiveFolderDetailInterface"),
                .package(product: "NetworkLayer"),
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain")
            ],
            exampleDependencies: [
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
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .package(product: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ArchiveDomain"),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
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
