import ProjectDescription
import ProjectDescriptionHelpers

let deploymentTarget: DeploymentTargets = .iOS("17.0")
let bundlePrefix = "com.carti"
let teamId = "L8DVKD4NCR"

let projectSettings: Settings = .settings(
    base: [
		"DEVELOPMENT_TEAM": "\(teamId)",
        "CODE_SIGN_STYLE": "Automatic"
    ]
)

let projectTargets: [Target] = {
	var targets: [Target] = [
	.target(
		name: "MSUtil",
		destinations: [.iPhone],
		product: .framework,
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
		product: .framework,
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
		product: .framework,
		bundleId: "\(bundlePrefix).MSData",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearch/Core/Data/**"],
		dependencies: [
			.target(name: "MSDomain"),
			.package(product: "NetworkLayer")
		],
		settings: projectSettings
	)
]

	targets.append(contentsOf: Target.microFeatureTargets(
	name: "Chart",
	bundlePrefix: bundlePrefix,
	deploymentTarget: deploymentTarget,
	settings: projectSettings,
	interfaceDependencies: [
		.target(name: "MSDomain"),
		.package(product: "MicroRIBs")
	],
	implementationDependencies: [
		.target(name: "MSDomain")
	],
	testingDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	],
	testsDependencies: [
		.target(name: "MSDomain")
	],
	exampleDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	]
))

	targets.append(contentsOf: Target.microFeatureTargets(
	name: "MusicDigging",
	bundlePrefix: bundlePrefix,
	deploymentTarget: deploymentTarget,
	settings: projectSettings,
	interfaceDependencies: [
		.target(name: "MSDomain")
	],
	implementationDependencies: [
		.target(name: "MSDomain")
	],
	testingDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	],
	testsDependencies: [
		.target(name: "MSDomain")
	],
	exampleDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	]
))

	targets.append(contentsOf: Target.microFeatureTargets(
	name: "TrackSearch",
	bundlePrefix: bundlePrefix,
	deploymentTarget: deploymentTarget,
	settings: projectSettings,
	interfaceDependencies: [
		.target(name: "MSDomain")
	],
	implementationDependencies: [
		.target(name: "FeatureMusicDiggingInterface"),
		.target(name: "FeatureMusicDigging"),
		.target(name: "MSDomain")
	],
	testingDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	],
	testsDependencies: [
		.target(name: "MSDomain")
	],
	exampleDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	]
))

	targets.append(contentsOf: Target.microFeatureTargets(
	name: "WeatherRecommendation",
	bundlePrefix: bundlePrefix,
	deploymentTarget: deploymentTarget,
	settings: projectSettings,
	interfaceDependencies: [
		.target(name: "MSDomain")
	],
	implementationDependencies: [
		.target(name: "MSDomain")
	],
	testingDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	],
	testsDependencies: [
		.target(name: "MSDomain")
	],
	exampleDependencies: [
		.target(name: "MSDomain"),
		.target(name: "MSUtil")
	]
))

	targets.append(contentsOf: [
	.target(
		name: "MusicSearch",
		destinations: [.iPhone],
		product: .app,
		bundleId: "\(bundlePrefix).MusicSearch",
		deploymentTargets: deploymentTarget,
		infoPlist: .file(path: "MusicSearch/App/Resources/Info.plist"),
		sources: ["MusicSearch/App/Sources/**"],
		dependencies: [
			.target(name: "FeatureChart"),
			.target(name: "FeatureChartInterface"),
			.target(name: "FeatureMusicDigging"),
			.target(name: "FeatureMusicDiggingInterface"),
			.target(name: "FeatureTrackSearch"),
			.target(name: "FeatureTrackSearchInterface"),
			.target(name: "FeatureWeatherRecommendation"),
			.target(name: "FeatureWeatherRecommendationInterface"),
			.target(name: "MSData")
		],
		settings: projectSettings
	),
	.target(
		name: "MusicSearchTests",
		destinations: [.iPhone],
		product: .unitTests,
		bundleId: "\(bundlePrefix).MusicSearchTests",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearchTests/**"],
		dependencies: [
			.target(name: "MusicSearch")
		],
		settings: projectSettings
	),
	.target(
		name: "MusicSearchUITests",
		destinations: [.iPhone],
		product: .uiTests,
		bundleId: "\(bundlePrefix).MusicSearchUITests",
		deploymentTargets: deploymentTarget,
		infoPlist: .default,
		sources: ["MusicSearchUITests/**"],
		dependencies: [
			.target(name: "MusicSearch")
		],
		settings: projectSettings
	)
])

	return targets
}()

let project = Project(
	name: "MusicSearch",
	packages: [
		.remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "8.0.0")),
		.remote(url: "https://github.com/carti1108/MicroRIBs", requirement: .branch("main")),
		.remote(url: "https://github.com/carti1108/NetworkLayer.git", requirement: .branch("main"))
	],
	settings: projectSettings,
	targets: projectTargets
)
