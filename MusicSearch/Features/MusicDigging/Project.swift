import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MusicDigging",
    packages: ProjectEnvironment.packages,
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "MusicDigging",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "MusicDigging",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "MusicDiggingDomain"),
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "MusicDiggingDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "MusicDiggingDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "MusicDiggingDomain")
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "MusicDiggingDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "Feature"
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(
            name: "FeatureMusicDiggingExample",
            buildAction: .buildAction(targets: ["FeatureMusicDiggingExample"])
        )
    ]
)