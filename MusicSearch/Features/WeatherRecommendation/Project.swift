import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "WeatherRecommendation",
    packages: ProjectEnvironment.packages,
    settings: ProjectEnvironment.projectSettings,
    targets: [
        [Target.domainTargets(
            name: "WeatherRecommendation",
            dependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MusicDiggingDomain", path: .relativeToRoot("MusicSearch/Features/MusicDigging"))
            ],
            basePath: "Shared"
        )],
        [Target.dataTargets(
            name: "WeatherRecommendation",
            dependencies: [
                .target(name: "WeatherRecommendationDomain"),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core"))
            ],
            basePath: "Shared"
        )],
        Target.microFeatureTargets(
            name: "WeatherRecommendation",
            interfaceDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "WeatherRecommendationDomain"),
                .package(product: "MicroRIBs")
            ],
            implementationDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "WeatherRecommendationDomain"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testingDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "WeatherRecommendationDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "FeatureWeatherRecommendation"),
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core"))
            ],
            testsDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "WeatherRecommendationDomain")
            ],
            exampleDependencies: [
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .target(name: "WeatherRecommendationDomain"),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core"))
            ],
            folderName: "Feature"
        )
    ].flatMap { $0 },
    schemes: [
        .scheme(
            name: "FeatureWeatherRecommendationExample",
            buildAction: .buildAction(targets: ["FeatureWeatherRecommendationExample"])
        )
    ]
)
