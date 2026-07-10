import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "TrackSearch",
    packages: ProjectEnvironment.packages,
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "TrackSearch",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        [Target.dataTargets(
            name: "TrackSearch",
            dependencies: [
                .target(name: "TrackSearchDomain"),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "TrackSearch",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "FeatureMusicDiggingInterface", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "MusicDiggingDomain", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .project(target: "FeatureMusicDiggingInterface", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "MusicDiggingDomain", path: .relativeToRoot("MusicSearch/Features/MusicDigging"))
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "Feature"
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(
            name: "FeatureTrackSearchExample",
            buildAction: .buildAction(targets: ["FeatureTrackSearchExample"])
        )
    ]
)