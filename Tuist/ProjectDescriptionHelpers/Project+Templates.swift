import ProjectDescription

public extension Target {
    
    static func domainTargets(
        name: String,
        bundlePrefix: String,
        deploymentTarget: DeploymentTargets,
        settings: Settings,
        dependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> Target {
        let path = basePath ?? "MusicSearch/Core/\(name)"
        let folder = folderName ?? "Domain"
        
        return Target.target(
            name: "\(name)Domain",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Domain",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(path)/\(folder)/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    static func dataTargets(
        name: String,
        bundlePrefix: String,
        deploymentTarget: DeploymentTargets,
        settings: Settings,
        dependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> Target {
        let path = basePath ?? "MusicSearch/Core/\(name)"
        let folder = folderName ?? "Data"
        
        return Target.target(
            name: "\(name)Data",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Data",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(path)/\(folder)/Sources/**"],
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
        exampleDependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> [Target] {
        let path = basePath ?? "MusicSearch/Features/\(name)"
        let folder = folderName ?? ""
        let resolvedPath = folder.isEmpty ? path : "\(path)/\(folder)"
        
        
        let interfaceTarget = Target.target(
            name: "Feature\(name)Interface",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)Interface",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(resolvedPath)/Interface/Sources/**"],
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
            sources: ["\(resolvedPath)/Sources/**"],
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
            sources: ["\(resolvedPath)/Testing/Sources/**"],
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
            sources: ["\(resolvedPath)/Tests/**"],
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
            sources: ["\(resolvedPath)/Example/Sources/**"],
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
