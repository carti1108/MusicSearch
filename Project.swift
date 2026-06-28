import ProjectDescription
import ProjectDescriptionHelpers

// MARK: - 앱 기본 설정
let deploymentTarget: DeploymentTargets = .iOS("17.0")
let bundlePrefix = "com.carti"

// MARK: - 프로젝트 빌드 세팅
let projectSettings: Settings = .settings(
    base: [
        "CODE_SIGN_IDENTITY": "",
        "CODE_SIGNING_REQUIRED": "NO",
        "CODE_SIGNING_ALLOWED": "NO",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "CLANG_ENABLE_MODULE_VERIFIER": "YES"
    ],
    configurations: [
        .debug(name: "Debug", xcconfig: .relativeToRoot("Config.xcconfig")),
        .release(name: "Release", xcconfig: .relativeToRoot("Config.xcconfig"))
    ]
)

// 앱 전용 설정 (자동 서명 활성화)
let appSettings: Settings = .settings(
    base: [
        "CODE_SIGN_STYLE": "Automatic",
        "CODE_SIGN_IDENTITY": "Apple Development",
        "CODE_SIGNING_REQUIRED": "YES",
        "CODE_SIGNING_ALLOWED": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "CLANG_ENABLE_MODULE_VERIFIER": "YES"
    ],
    configurations: [
        .debug(name: "Debug", xcconfig: .relativeToRoot("Config.xcconfig")),
        .release(name: "Release", xcconfig: .relativeToRoot("Config.xcconfig"))
    ]
)

// MARK: - 프로젝트 타겟(모듈) 정의

// 1. 공통 모듈 (Core / Shared)
let coreTargets: [Target] = [
	.target(
		name: "MSDesignSystem",
		destinations: [.iPhone],
		product: .staticFramework,
		bundleId: "\(bundlePrefix).MSDesignSystem",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearch/Core/DesignSystem/**"],
		settings: projectSettings
	),
	.target(
		name: "MSUtil",
		destinations: [.iPhone],
		product: .staticFramework,
		bundleId: "\(bundlePrefix).MSUtil",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearch/Core/Util/**"],
		dependencies: [
			.package(product: "Kingfisher")
		],
		settings: projectSettings
	),
	.target(
		name: "MSDomain",
		destinations: [.iPhone],
		product: .staticFramework,
		bundleId: "\(bundlePrefix).MSDomain",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearch/Core/Domain/**"],
		dependencies: [
			.target(name: "MSUtil")
		],
		settings: projectSettings
	),
	.target(
		name: "MSData",
		destinations: [.iPhone],
		product: .staticFramework,
		bundleId: "\(bundlePrefix).MSData",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearch/Core/Data/**"],
		dependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.package(product: "NetworkLayer")
		],
		settings: projectSettings
	)
]

// 2. 도메인 및 데이터 계층 생성 (Helper 메서드 사용)
let domainDataTargets: [Target] = [
	Target.domainTargets(name: "Chart", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "MSDomain"), .target(name: "TrackSearchDomain")]),
	Target.dataTargets(name: "Chart", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "ChartDomain"), .target(name: "MSData")]),
	Target.domainTargets(name: "TrackSearch", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "MSDomain")]),
	Target.dataTargets(name: "TrackSearch", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "TrackSearchDomain"), .target(name: "MSData")]),
	Target.domainTargets(name: "MusicDigging", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "MSDomain"), .target(name: "TrackSearchDomain")]),
	Target.domainTargets(name: "WeatherRecommendation", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "MSDomain"), .target(name: "MusicDiggingDomain")]),
	Target.dataTargets(name: "WeatherRecommendation", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "WeatherRecommendationDomain"), .target(name: "MSData")]),
	Target.domainTargets(name: "Archive", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "MSDomain")]),
	Target.dataTargets(name: "Archive", bundlePrefix: bundlePrefix, deploymentTarget: deploymentTarget, settings: projectSettings, dependencies: [.target(name: "ArchiveDomain"), .target(name: "MSData")])
]

// 3. UI 및 비즈니스 로직 계층 (MicroFeature) 생성
let featureTargets: [Target] = [
	Target.microFeatureTargets(
		name: "Chart",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ChartDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ChartDomain"),
			.target(name: "MSDesignSystem")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ChartDomain"),
			.target(name: "MSUtil")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ChartDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ChartDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "MusicDigging",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "MusicDiggingDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "MusicDiggingDomain"),
			.target(name: "MSDesignSystem")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "MusicDiggingDomain"),
			.target(name: "MSUtil")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "MusicDiggingDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "MusicDiggingDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "TrackSearch",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "FeatureMusicDiggingInterface"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MSDesignSystem")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MusicDiggingDomain"),
			.target(name: "FeatureMusicDiggingInterface"),
			.target(name: "MSUtil")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MusicDiggingDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "WeatherRecommendation",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "WeatherRecommendationDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "WeatherRecommendationDomain"),
			.target(name: "MSDesignSystem")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "WeatherRecommendationDomain"),
			.target(name: "MSUtil")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "WeatherRecommendationDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "WeatherRecommendationDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "Archive",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "FeatureAddArchiveInterface"),
			.target(name: "FeatureArchiveSearchInterface"),
			.target(name: "FeatureArchiveFolderInterface"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.target(name: "FeatureSettingsInterface"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "FeatureAddArchiveInterface"),
			.target(name: "FeatureArchiveSearchInterface"),
			.target(name: "FeatureArchiveFolderInterface"),
			.target(name: "FeatureArchiveFolderDetail"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.target(name: "FeatureSettingsInterface"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "ArchiveFolderDetail",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.package(product: "NetworkLayer"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "AddArchive",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "TrackSearchDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.package(product: "NetworkLayer"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "FeatureTrackSearchTesting"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "TrackSearchDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "TrackSearchDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "ArchiveFolder",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.package(product: "NetworkLayer"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "ArchiveSearch",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.package(product: "NetworkLayer"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil")
		]
	),
	Target.microFeatureTargets(
		name: "Settings",
		bundlePrefix: bundlePrefix,
		deploymentTarget: deploymentTarget,
		settings: projectSettings,
		interfaceDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.package(product: "MicroRIBs")
		],
		implementationDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.package(product: "NetworkLayer"),
			.package(product: "ComposableArchitecture")
		],
		testingDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil"),
			.package(product: "ComposableArchitecture")
		],
		testsDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain")
		],
		exampleDependencies: [
			.target(name: "MSDomain"),
			.target(name: "ArchiveDomain"),
			.target(name: "MSUtil")
		]
	)
].flatMap { $0 }

// 4. 최종 앱(App) 타겟 생성
let appTargets: [Target] = [
	.target(
		name: "MusicSearch",
		destinations: [.iPhone],
		product: .app,
		bundleId: "\(bundlePrefix).MusicSearch",
		deploymentTargets: deploymentTarget,
		infoPlist: .extendingDefault(with: [
			"OPENWEATHERMAP_API_KEY": "$(OPENWEATHERMAP_API_KEY)",
			"LASTFM_API_KEY": "$(LASTFM_API_KEY)",
			"SPOTIFY_CLIENT_ID": "$(SPOTIFY_CLIENT_ID)",
			"NSLocationWhenInUseUsageDescription": "현재 위치의 날씨 정보를 제공하기 위해 위치 권한이 필요합니다.",
			"UILaunchStoryboardName": "LaunchScreen",
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
		sources: ["MusicSearch/App/Sources/**"],
		resources: ["MusicSearch/App/Resources/**"],
		dependencies: [
			.target(name: "FeatureChart"),
			.target(name: "FeatureChartInterface"),
			.target(name: "FeatureMusicDigging"),
			.target(name: "FeatureMusicDiggingInterface"),
			.target(name: "FeatureTrackSearch"),
			.target(name: "FeatureTrackSearchInterface"),
			.target(name: "FeatureWeatherRecommendation"),
			.target(name: "FeatureWeatherRecommendationInterface"),
			.target(name: "FeatureArchive"),
			.target(name: "FeatureArchiveInterface"),
			.target(name: "FeatureAddArchive"),
			.target(name: "FeatureAddArchiveInterface"),
			.target(name: "FeatureArchiveFolder"),
			.target(name: "FeatureArchiveFolderInterface"),
			.target(name: "FeatureArchiveFolderDetail"),
			.target(name: "FeatureArchiveFolderDetailInterface"),
			.target(name: "FeatureArchiveSearch"),
			.target(name: "FeatureArchiveSearchInterface"),
			.target(name: "FeatureSettings"),
			.target(name: "FeatureSettingsInterface"),
			.target(name: "MSDesignSystem"),
			.target(name: "MSData"),
			.target(name: "ChartData"),
			.target(name: "TrackSearchData"),
			.target(name: "WeatherRecommendationData"),
			.target(name: "ArchiveDomain"),
			.target(name: "ArchiveData"),
			.target(name: "MSDomain"),
			.target(name: "MSUtil"),
			.package(product: "NetworkLayer"),
			.package(product: "MicroRIBs")
		],
		settings: appSettings
	)
]

let projectTargets: [Target] = coreTargets + domainDataTargets + featureTargets + appTargets

// MARK: - 최종 프로젝트 조립
let project = Project(
	name: "MusicSearch",
	packages: [
		.remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "8.0.0")),
		.remote(url: "https://github.com/carti1108/MicroRIBs", requirement: .branch("main")),
		.remote(url: "https://github.com/carti1108/NetworkLayer.git", requirement: .branch("main")),
		.remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.10.0"))
	],
	settings: projectSettings,
	targets: projectTargets
)
