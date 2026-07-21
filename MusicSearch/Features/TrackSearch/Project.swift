import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "TrackSearch",
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
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "TrackSearch",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "FeatureMusicDiggingInterface", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .external(name: "MicroRIBs")
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
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureTrackSearch")
            ],
            testsDependencies: [
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "TrackSearchDomain"),
                .project(target: "MusicDiggingDomain", path: .relativeToRoot("MusicSearch/Features/MusicDigging"))
            ,
                .external(name: "NetworkLayer")],
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
