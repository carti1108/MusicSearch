import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Settings",
    settings: ProjectEnvironment.projectSettings,
    targets: [
        Target.microFeatureTargets(
            name: "Settings",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .external(name: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "FeatureArchiveFolderDetailInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .external(name: "NetworkLayer"),
                .external(name: "ComposableArchitecture")
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .external(name: "ComposableArchitecture")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive"))
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
            ],
            folderName: ""
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(name: "FeatureSettingsExample", buildAction: .buildAction(targets: ["FeatureSettingsExample"]))
    ]
)
