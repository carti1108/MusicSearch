import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Chart",
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "Chart",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "TrackSearchDomain", path: .relativeToRoot("MusicSearch/Features/TrackSearch"))
            ],
            basePath: "Shared"
        )],
        [Target.dataTargets(
            name: "Chart",
            dependencies: [
                .target(name: "ChartDomain"),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "Chart",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .external(name: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureChart")
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSTesting", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain")
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "Feature"
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(
            name: "FeatureChartExample",
            buildAction: .buildAction(targets: ["FeatureChartExample"])
        )
    ]
)
