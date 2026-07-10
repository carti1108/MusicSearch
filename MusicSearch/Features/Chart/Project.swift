import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Chart",
    packages: ProjectEnvironment.packages,
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
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "Chart",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "ChartDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
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