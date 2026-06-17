import ProjectDescription

public extension Target {
    
    static func domainTargets(
        name: String,
        bundlePrefix: String,
        deploymentTarget: DeploymentTargets,
        settings: Settings,
        dependencies: [TargetDependency] = []
    ) -> Target {
        return Target.target(
            name: "\(name)Domain",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Domain",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Core/\(name)/Domain/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    static func dataTargets(
        name: String,
        bundlePrefix: String,
        deploymentTarget: DeploymentTargets,
        settings: Settings,
        dependencies: [TargetDependency] = []
    ) -> Target {
        return Target.target(
            name: "\(name)Data",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Data",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Core/\(name)/Data/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    static func microFeatureTargets(
        name: String,
        bundlePrefix: String,
        deploymentTarget: DeploymentTargets,
        settings: Settings,
        interfaceDependencies: [TargetDependency] = [],
        implementationDependencies: [TargetDependency] = [],
        testingDependencies: [TargetDependency] = [],
        testsDependencies: [TargetDependency] = [],
        exampleDependencies: [TargetDependency] = []
    ) -> [Target] {
        
        let interfaceTarget = Target.target(
            name: "Feature\(name)Interface",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)Interface",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Features/\(name)/Interface/Sources/**"],
            dependencies: interfaceDependencies,
            settings: settings
        )
        
        let implementationTarget = Target.target(
            name: "Feature\(name)",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Features/\(name)/Sources/**"],
            dependencies: implementationDependencies + [.target(name: "Feature\(name)Interface")],
            settings: settings
        )
        
        let testingTarget = Target.target(
            name: "Feature\(name)Testing",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)Testing",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Features/\(name)/Testing/Sources/**"],
            dependencies: testingDependencies + [.target(name: "Feature\(name)Interface")],
            settings: settings
        )
        
        let testsTarget = Target.target(
            name: "Feature\(name)Tests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(bundlePrefix).Feature\(name)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["MusicSearch/Features/\(name)/Tests/Sources/**"],
            dependencies: testsDependencies + [.target(name: "Feature\(name)"), .target(name: "Feature\(name)Testing")],
            settings: settings
        )
        
        let exampleTarget = Target.target(
            name: "Feature\(name)Example",
            destinations: [.iPhone],
            product: .app,
            bundleId: "\(bundlePrefix).Feature\(name)Example",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
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
            sources: ["MusicSearch/Features/\(name)/Example/Sources/**"],
            dependencies: exampleDependencies + [
                .target(name: "Feature\(name)"),
                .target(name: "Feature\(name)Interface"),
                .target(name: "Feature\(name)Testing")
            ],
            settings: settings
        )
        
        return [
            interfaceTarget,
            implementationTarget,
            testingTarget,
            testsTarget,
            exampleTarget
        ]
    }
}
