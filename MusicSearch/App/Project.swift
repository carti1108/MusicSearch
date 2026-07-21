import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "MusicSearchApp",
    settings: ProjectEnvironment.projectSettings,
    targets: [
        .target(
            name: "MusicSearch",
            destinations: [.iPhone],
            product: .app,
            bundleId: "\(ProjectEnvironment.bundlePrefix).MusicSearch",
            deploymentTargets: ProjectEnvironment.deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "OPENWEATHERMAP_API_KEY": "$(OPENWEATHERMAP_API_KEY)",
                "LASTFM_API_KEY": "$(LASTFM_API_KEY)",
                "SPOTIFY_CLIENT_ID": "$(SPOTIFY_CLIENT_ID)",
                "SPOTIFY_CLIENT_SECRET": "$(SPOTIFY_CLIENT_SECRET)",
                "NSLocationWhenInUseUsageDescription": "현재 위치의 날씨 정보를 제공하기 위해 위치 권한이 필요합니다.",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIUserInterfaceStyle": "Dark",
                "LSApplicationQueriesSchemes": ["spotify"],
                "CFBundleURLTypes": [
                    [
                        "CFBundleURLName": "com.carti.MusicSearch",
                        "CFBundleURLSchemes": ["musicsearch"]
                    ]
                ],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                            ]
                        ]
                    ]
                ]
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "FeatureChart", path: .relativeToRoot("MusicSearch/Features/Chart")),
                .project(target: "FeatureChartInterface", path: .relativeToRoot("MusicSearch/Features/Chart")),
                .project(target: "FeatureMusicDigging", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .project(target: "FeatureMusicDiggingInterface", path: .relativeToRoot("MusicSearch/Features/MusicDigging")),
                .project(target: "FeatureTrackSearch", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureTrackSearchInterface", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "FeatureWeatherRecommendation", path: .relativeToRoot("MusicSearch/Features/WeatherRecommendation")),
                .project(target: "FeatureWeatherRecommendationInterface", path: .relativeToRoot("MusicSearch/Features/WeatherRecommendation")),
                
                .project(target: "FeatureArchive", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureAddArchive", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureAddArchiveInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveFolder", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveFolderInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveFolderDetail", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveFolderDetailInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveSearch", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveSearchInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveTrackSearch", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "FeatureArchiveTrackSearchInterface", path: .relativeToRoot("MusicSearch/Features/Archive")),
                
                .project(target: "FeatureSettings", path: .relativeToRoot("MusicSearch/Features/Settings")),
                .project(target: "FeatureSettingsInterface", path: .relativeToRoot("MusicSearch/Features/Settings")),
                
                .project(target: "MSDesignSystem", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSData", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSInfrastructure", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "ChartData", path: .relativeToRoot("MusicSearch/Features/Chart")),
                .project(target: "TrackSearchData", path: .relativeToRoot("MusicSearch/Features/TrackSearch")),
                .project(target: "WeatherRecommendationData", path: .relativeToRoot("MusicSearch/Features/WeatherRecommendation")),
                .project(target: "ArchiveDomain", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "ArchiveData", path: .relativeToRoot("MusicSearch/Features/Archive")),
                .project(target: "MSDomain", path: .relativeToRoot("MusicSearch/Core")),
                .project(target: "MSUtil", path: .relativeToRoot("MusicSearch/Core")),
                
                .external(name: "NetworkLayer"),
                .external(name: "MicroRIBs")
            ],
            settings: ProjectEnvironment.appSettings
        )
    ]
)
